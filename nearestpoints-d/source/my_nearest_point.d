module my_nearest_point;

import std.algorithm.iteration : map;
import std.algorithm.sorting : isSorted;
import std.format : format;
import std.math : approxEqual;
import std.random;
import std.stdio;

struct Point 
{
	double x;
	double y;

	bool opEquals(const Point other) const 
	{
		return approxEqual(this.x, other.x) && approxEqual(this.y, other.y);
	}
}

struct PointDis 
{
	Point p;
	double d;

	int opCmp(ref const PointDis other) const
	{
		return d < other.d ? -1 : d > other.d ? 1 : 0;
	}
}

// Since we do not care about the real distance in our final function we can compare sqaured
// distances in order to avoid the sqrt operation.

// the same code is produced for the three kinds of pow2 impl (on ldc 1.20, gdc 9.2)
// see: https://godbolt.org/z/vPP_4V
// however on dmd 2.089.0 the pow call generate more code and a function call (see: https://godbolt.org/z/iPEXe-)
double distance2(const(Point) a, const(Point) b) 
{
	return (a.x - b.x)^^2 + (a.y - b.y)^^2;
}

double distance(const(Point) a, const(Point) b) 
{
	import std.math : sqrt;
	return sqrt(distance2(a, b));
}

// base algorithm is O(n log n) because of sort func (see: https://dlang.org/phobos/std_algorithm_sorting.html#sort)

Point[] nearestPointAppender(Input)(Input input, const(Point) center, size_t n) 
{
	import std.algorithm: sort;
	import std.array: array, appender, Appender;
	import std.range: assumeSorted, SearchPolicy;

	// using appender instead of regular array allow more efficient memory allocation
	auto app = appender!(PointDis[]);

	bool sorted = false;
	foreach(Point it; input)
	{
		PointDis pd = PointDis(it, distance2(center, it));

		if(app[].length < n)
		{
			app ~= pd;
		}
		else
		{
			// sort array only once
			if (!sorted)
			{
				sort(app[]);
				sorted = true;
			}

			// we can do binary search since the array is already sorted 
			auto greaterRange = assumeSorted(app[]).upperBound!(SearchPolicy.binarySearch)(pd);
			if (greaterRange.length > 0)
				greaterRange.front = pd;
		}
	}

	if (!sorted)
		sort(app[]);
	
	return app[].map!(it => it.p).array;
}

Point rndPoint(ref Random rnd) 
{
	return Point(uniform(-20.0, 20.0, rnd), uniform(-20.0, 20.0, rnd));
}

struct PointRng 
{
	long cnt;
	Point front;
	Random rnd;
	
	// using @property is not recommended
	// see: https://dlang.org/spec/function.html#property-functions
	bool empty() const 
	{
		return this.cnt <= 0;
	}

	void popFront() 
	{
		this.front = rndPoint(this.rnd);
		this.cnt--;
	}
}

PointRng pointRng(long cnt, uint seed) 
{
	PointRng ret;
	ret.rnd = Random(seed);
	ret.cnt = cnt;
	ret.front = rndPoint(ret.rnd);
	return ret;
}

// fastest method so far
// alias is used to check the tests
alias nearestPoint = nearestPointAppender;