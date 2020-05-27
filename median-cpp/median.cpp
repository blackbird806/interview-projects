#include "median.hpp"

#include <stdexcept>
#include <algorithm>
#include <random>
#include <cassert>

#define MY_QUICKSELECT

#ifdef SORT_MEDIAN

double median(const std::vector<int>& numbers) {
    if(numbers.size() == 0)
        throw std::invalid_argument("No median for empty vector");

    auto mutableNumbers = numbers;
    std::sort(mutableNumbers.begin(), mutableNumbers.end());

    const bool isOdd = numbers.size() % 2;

    return isOdd
        ? mutableNumbers[numbers.size() / 2]
        : (mutableNumbers[numbers.size() / 2 - 1] + mutableNumbers[numbers.size() / 2]) / 2.0;
}

#elif defined(MY_QUICKSELECT)

// quickselect algorithm, average complexity is O(n) worst case is O(n log n)
// based on: https://rcoh.me/posts/linear-time-median-finding/
double quickselect(std::vector<int>::iterator first, std::vector<int>::iterator last, size_t nth)
{
	auto const len = std::distance(first, last);

	if (len == 1)
	{
		assert(nth == 0);
		return *first;
	}

	// choose a random pivot in the array / sub-array
	std::default_random_engine random_generator;
	std::uniform_int_distribution<int> distribution(0, static_cast<int>(len) - 1);
	int const pivot = first[distribution(random_generator)];

	// partition the vector in order to regroup all elem that are less than the pivot
	// complexity of std::partition is O(n) see: https://en.cppreference.com/w/cpp/algorithm/partition
	auto const low_end = std::partition(first, last, [pivot](auto const& e)
		{
			return e < pivot;
		});

	// get all elements that are equal with the pivot
	auto const pivots_start = low_end;
	auto const pivots_end = std::partition(low_end, last, [pivot](auto const& e)
		{
			return e == pivot;
		});

	auto const up_start = pivots_end;
	auto const low_size = std::distance(first, low_end);
	auto const pivot_size = std::distance(pivots_start, pivots_end);

	// at this point the array / sub-array is partitionned like this
	// [first .. low_end] [pivots_start .. pivots_end] [up_start .. last]
	// 
	// where the range [first .. low_end] contains all elements that are less than the pivot
	// [pivots_start .. pivots_end] contains all elements that are equal to the pivot
	// [up_start .. last] contains all elements higher than the pivot

	assert(low_size >= 0);
	assert(pivot_size >= 0);

	// if the nth is contained in the lower range recurse on it
	if (nth < static_cast<size_t>(low_size))
		return quickselect(first, low_end, nth);

	// if the nth is in the pivot range then nth is the median of this array / sub-array
	if (nth < static_cast<size_t>(low_size + pivot_size))
		return *low_end;

	// else if the th_element is contained in the upper range recurse on it
	// search for the {nth - low_size - pivot_size} since we recurse on the upper range
	return quickselect(up_start, last, nth - low_size - pivot_size);
}

double median(std::vector<int> const& numbers) {

    size_t const array_size = std::size(numbers);
	
	if(array_size == 0)
        throw std::invalid_argument("No median for empty vector");

	// work on a copy since quickselect func will modify the array
	std::vector<int> cpy(numbers);

	bool const is_odd = array_size % 2 == 1;
	
	if (is_odd)
	// if the array is odd, the median is the {array_size / 2} smallest element of the array
		return quickselect(cpy.begin(), cpy.end(), array_size / 2);
	
	return 0.5 * 
		 (	quickselect(cpy.begin(), cpy.end(), array_size / 2 - 1) + 
			quickselect(cpy.begin(), cpy.end(), array_size / 2)	);
}

#else

// this implementation uses std::nth_element which have O(n) average complexity too 

double median(std::vector<int> const& numbers) {

	size_t const array_size = std::size(numbers);

	if (array_size == 0)
		throw std::invalid_argument("No median for empty vector");

	// work on a copy since std::nth_element func will modify the array
	std::vector<int> cpy(numbers);

	bool const is_odd = array_size % 2 == 1;
	
	// if the array is odd, the median is the {array_size / 2} smallest element of the array

	// according to the standard :
	// "The element pointed at by nth is changed to whatever element would occur in that position if [first, last) were sorted. "
	// see: https://en.cppreference.com/w/cpp/algorithm/nth_element
	// so if the array length is odd the median is placed at {cpy.begin() + array_size / 2}
	std::nth_element(cpy.begin(), cpy.begin() + array_size / 2, cpy.end());

	if (is_odd)
		return cpy[array_size / 2];
	
	int const n1 = cpy[array_size / 2];
	
	// if the array length is even then we need to compute the average between elements placed at {array_size / 2} and {array_size / 2 - 1} 
	// we need to call a second time nth_element in order to get the {array_size / 2 - 1} smallest element of the array
	std::nth_element(cpy.begin(), cpy.begin() + array_size / 2 - 1, cpy.end());
	int const n2 = cpy[array_size / 2 - 1];

	// cast to long long to avoid int overflow
	return 0.5 * (static_cast<long long int>(n1) + static_cast<long long int>(n2));
}

#endif
