
source("data_processing_functions.R")

context("Testing for edge cases in the cleaned_data() function")

test_that("Location vec has same dimention as the number of rows of poland_species_subset",{
  expect_equal(cleaned_data(poland_species_data)[[2]],cleaned_data(poland_species_data)[[3]])
})

test_that("We have no missing values",{
  expect_equal(cleaned_data(poland_species_data)[[4]],0)
})

test_that("Location vec does not have char '-' ",{
  expect_equal(cleaned_data(poland_species_data)[[5]],FALSE)
})

test_that("Location vec does not have char '/' ",{
  expect_equal(cleaned_data(poland_species_data)[[6]],FALSE)
})

