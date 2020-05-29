module my_nearest_point_tests;

import std.algorithm.iteration : map;
import std.algorithm.sorting : isSorted;
import std.format : format;
import std.math : approxEqual;
import std.random;
import std.stdio;

import my_nearest_point;

unittest {
	Point a = Point(1.0, 2.0);
	Point b = Point(2.0, 1.0);
	Point c = Point(-1.0, 2.0);
	Point d = Point(-1.0, -2.0);
	Point e = Point(0.0, 0.0);

	{
		const double r0 = distance(a, b);
		const double r1 = distance(b, a);

		assert(approxEqual(r0, r1), format("%s %s", r0, r1));
	}

	{
		const double r0 = distance(a, c);
		const double r1 = distance(b, a);

		assert(!approxEqual(r0, r1), format("%s %s", r0, r1));
	}

	{
		const double r0 = distance(e, d);
		const double r1 = distance(e, a);

		assert(approxEqual(r0, r1), format("%s %s", r0, r1));
	}
}

unittest {
	import std.algorithm.comparison : equal;
	auto p1 = pointRng(10, 1337);
	auto p2 = pointRng(10, 1337);
	assert(equal(p1, p2));
}

unittest {
	auto center = Point(0.0, 0.0);
	const auto rslt = nearestPoint(pointRng(2000, 1338), center, 10);
	assert(rslt.length == 10);
	assert(rslt.map!(it => distance(center, it)).isSorted);
}

unittest {
	const auto center = Point(0.0, 0.0);
	const auto rslt = nearestPoint(pointRng(7, 1338), center, 10);
	assert(rslt.length == 7);
	assert(rslt.map!(it => distance(center, it)).isSorted);
}

unittest {
    const points = [
        Point(0, 10),
        Point(10, 0),
        Point(10, 10),
        Point(-10, -10),
        Point(1, 0),
        Point(0, 1),
        Point(-1, 0),
        Point(0, 1),
    ];
    const center = Point(0.0, 0.0);
    const nearest = nearestPoint(points, center, 4);
    const expected = [
        Point(1, 0),
        Point(0, 1),
        Point(-1, 0),
        Point(0, 1),
    ];

    import std.conv: text;
    assert(nearest == expected, nearest.text);
}