module base_nearest_point;

import std.algorithm.iteration : map;
import std.algorithm.sorting : isSorted;
import std.format : format;
import std.math : approxEqual;
import std.random;
import std.stdio;

struct Point {
	double x;
	double y;

	bool opEquals(const Point other) const {
		return approxEqual(this.x, other.x) && approxEqual(this.y, other.y);
	}
}

struct PointDis {
	Point p;
	double d;
}

double distance(const(Point) a, const(Point) b) {
	import std.math : pow, sqrt;
	return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
}


Point[] nearestPoint(Input)(Input input, const(Point) center, size_t n) {
	import std.algorithm.sorting : sort;
	import std.array : array;

	PointDis[] tmp;

	foreach(Point it; input) {
		PointDis pd = PointDis(it, distance(center, it));
		if(tmp.length < n) {
			tmp ~= pd;
			sort!((a, b) => a.d < b.d)(tmp);
		} else {
			foreach(ref p; tmp) {
				if(pd.d < p.d) {
					p = pd;
					break;
				}
			}
		}
	}

	return tmp.map!(it => it.p).array;
}

Point rndPoint(ref Random rnd) {
	return Point(uniform(-20.0, 20.0, rnd), uniform(-20.0, 20.0, rnd));
}

struct PointRng {
	long cnt;
	Point front;
	Random rnd;
	
	@property bool empty() const {
		return this.cnt <= 0;
	}

	void popFront() {
		this.front = rndPoint(this.rnd);
		this.cnt--;
	}
}

PointRng pointRng(long cnt, uint seed) {
	PointRng ret;
	ret.rnd = Random(seed);
	ret.cnt = cnt;
	ret.front = rndPoint(ret.rnd);
	return ret;
}
