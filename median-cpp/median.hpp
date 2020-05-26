#ifndef MEDIAN_HPP
#define MEDIAN_HPP

#include <vector>

#include <stdexcept>
#include <algorithm>
#include <type_traits>
#include <cassert>
#include <time.h>
#include <stdlib.h>

double median(const std::vector<int>& numbers);

// the templates were added because of the attempt of the function quickselectOn (see below)
// which need to find the median of a vector<double>

// quickselect algorithm, average complexity is O(n) worst case is O(n log n)
// based on: https://rcoh.me/posts/linear-time-median-finding/
template<typename T>
double quickselect(typename std::vector<T>::iterator first, typename std::vector<T>::iterator last, size_t k)
{
	size_t const len = std::distance(first, last);

	if (len == 1)
	{
		assert(k == 0);
		return *first;
	}

	int const pivot = first[rand() % len];

	// partition the vector in order to regroup all elem that are less than the pivot
	auto const low_end = std::partition(first, last, [pivot](auto const& e)
	{
		return e < pivot;
	});

	// get all elements that are equal with the pivot
	auto const pivotsStart = low_end;
	auto const pivotsEnd = std::partition(low_end, last, [pivot](auto const& e)
	{
		return e == pivot;
	});

	auto const up = pivotsEnd;
	size_t const low_size = std::distance(first, low_end);
	size_t const pivot_size = std::distance(pivotsStart, pivotsEnd);

	if (k < low_size)
		return quickselect<T>(first, low_end, k);
	if (k < low_size + pivot_size)
		 return *low_end;

	return quickselect<T>(up, last, k - low_size - pivot_size);
}

// get split view of n elements of vec
template<typename T>
auto chunk_vector(std::vector<T>& vec, unsigned int n)
{
	unsigned int const num = vec.size() / n;

	int startIdx = 0;
	int endIdx = n;

	std::vector<
		std::pair<
			typename std::vector<T>::iterator,
			typename std::vector<T>::iterator
			>
		> chunked_view;

	chunked_view.reserve(n);
	for (unsigned int i = 0; i < num; i++)
	{
		chunked_view.emplace_back(vec.begin() + startIdx, vec.begin() + endIdx);
		startIdx += n;
		endIdx += n;
	}

	return chunked_view;
}


template<typename T>
double median(const std::vector<T>& numbers);

// attempt to implement determinist O(n) quickselect algorithm
template<typename T>
double quickselectOn(std::vector<T>& numbers, size_t k)
{
	assert(!numbers.empty());

	if (numbers.size() < 5)
		return quickselect<T>(numbers.begin(), numbers.end(), k);

	auto chunks = chunk_vector(numbers, 5);

	// remove chunks that are not full
	chunks.erase(
		std::remove_if(chunks.begin(), chunks.end(),
		[](auto const& e){
			return std::distance(e.first, e.second) < 5;
		}),
		chunks.end());

	std::vector<double> medians;
	medians.reserve(chunks.size());

	for (auto const& [start, end] : chunks)
	{
		std::sort(start, end);
		medians.push_back(start[2]); // median of a sorted 5 length array is at index 2
	}

	// our result is the median of medians
	// this is why I needed templates
	return median(medians);
}

template<typename T>
double median(const std::vector<T>& numbers)
{
	static_assert(std::is_arithmetic_v<T>);

	size_t const array_size = std::size(numbers);

	if(array_size == 0)
        throw std::invalid_argument("No median for empty vector");

	bool const is_odd = array_size % 2 == 1;

	std::vector<T> cpy(numbers);

	if (is_odd)
		return quickselectOn(cpy, array_size / 2);

	return 0.5 * (quickselectOn(cpy, array_size / 2 - 1) + quickselectOn(cpy, array_size / 2));
}

#endif
