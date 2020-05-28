module my_median;

import std.range.primitives: isInputRange, ElementType;
import std.traits: Unqual, isNumeric;

bool isOdd(T)(T num)
    if (isNumeric!T)
{
    return num % 1 == 1;
}

// this is almost the same implementation as in c++
auto quickselect(R)(R numbers, size_t nth)
    if(isInputRange!R && is(Unqual!(ElementType!R) == int))
{
    import std.typecons: Tuple;
    
    if (numbers.length == 1)
    {
        assert(nth == 0);
        return numbers[0];
    }

    alias partitionRanges = Tuple!(
        R, "lower", 
        R, "pivots",
        R, "upper");

    version (USE_PARTTION3)
    {
        import std.algorithm.sorting: partition3;
        import std.random: choice;

        // this version pass the tests but crash in the benchmarks
        // according to the doc partition3 isn't stable yet
        // see: https://dlang.org/phobos/std_algorithm_sorting.html#partition3
        const int pivot = choice(numbers);
        partitionRanges ranges = numbers.partition3(pivot);
    }
    else
    {
        import std.algorithm.sorting: pivotPartition;
        import std.random: uniform;
        
        // the main weakness of this algorithm is the random pivot
        // if we're unlucky we can pick only bad pivots (pivots that does not split evenly the array)
        // this may result in worse complexity
        size_t pivotIndex = uniform(0, numbers.length);
        const size_t newPivotIndex = numbers.pivotPartition(pivotIndex);
        partitionRanges ranges;
        ranges.lower = numbers[0 .. newPivotIndex];
        // since without partition3 finding the pivots range is not trivial we will ignore it
        // the algo works fine without (it may be a little bit slower though)
        ranges.upper = numbers[newPivotIndex .. $];
    }

    if (nth < ranges.lower.length)
        return quickselect(ranges.lower, nth);
    if (nth < ranges.lower.length + ranges.pivots.length)
        return ranges.pivots[0];

    return quickselect(ranges.upper, nth - ranges.pivots.length - ranges.lower.length);
} 

double median(R)(R numbers)
    if(isInputRange!R && is(Unqual!(ElementType!R) == int))
{
    import std.array: empty, front, array;
    import std.algorithm: sort;

    if(numbers.empty)
        throw new Exception("No median for empty range");

    auto arr = numbers.array.dup;

    if (arr.length.isOdd)
        return quickselect(arr, arr.length / 2);

    return 0.5 * (quickselect(arr, arr.length / 2) + quickselect(arr, arr.length / 2 - 1));
}
