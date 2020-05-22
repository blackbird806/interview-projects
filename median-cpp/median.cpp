#include "median.hpp"

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

#else

double median(std::vector<int> const& numbers) {

    size_t const array_size = std::size(numbers);
	
	if(array_size == 0)
        throw std::invalid_argument("No median for empty vector");
    
	std::vector<int> cpy(numbers);

	 if (array_size % 2 == 1)
	 	return quickselect<int>(cpy.begin(), cpy.end(), array_size / 2);

	 return 0.5 * (quickselect<int>(cpy.begin(), cpy.end(), array_size / 2 - 1) + quickselect<int>(cpy.begin(), cpy.end(), array_size / 2));
}

#endif