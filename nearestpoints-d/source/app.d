import std.stdio : writeln;
import std.algorithm.iteration : map;
import std.datetime.stopwatch : benchmark; 

void runBenchmark(uint iterations, uint numPoints)
{
	{
		import base_nearest_point;
		
		const auto center = Point(0.0, 0.0);
		const auto results = benchmark!({ nearestPoint(pointRng(7, 1338), center, numPoints); })(iterations);
		writeln("base nearestPoint: ", results[0]);
	}
	{
		import my_nearest_point;
		
		const auto center = Point(0.0, 0.0);
		const auto results = benchmark!({ nearestPointAppender(pointRng(7, 1338), center, numPoints); })(iterations);
		writeln("nearestPointAppender: ", results[0]);
	}
	{
		import my_nearest_point;
		
		const auto center = Point(0.0, 0.0);
		const auto results = benchmark!({ nearestPointHeap(pointRng(7, 1338), center, numPoints); })(iterations);
		writeln("nearestPointHeapify: ", results[0]);
	}
}

void main() {
	// auto center = Point(0.0, 0.0);
	// auto rslt = nearestPoint(pointRng(2000, 1338), center, 10);
	// writeln(rslt);
	// writeln(rslt.map!(it => distance(center, it)));

	writeln("benchmarks : ");
	
	enum iterations = 100_000;

	writeln("array 10");
	runBenchmark(iterations, 10);

	writeln("array 100");
	runBenchmark(iterations, 100);

	writeln("array 10_000");
	runBenchmark(iterations, 10_000);

	writeln("array 1_000_000");
	runBenchmark(iterations, 1_000_000);
}
