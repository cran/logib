# Test whether the included example file is the same as the downloaded one
test_that("The included example file is identical to the downloaded example file", {
  download_example_datalist(testthat::test_path("Example_data_sheet_M1.xlsx"),
                            language = "en")
  data <- read_data(testthat::test_path("Example_data_sheet_M1.xlsx"))
  expect_true(all(datalist_example == data, na.rm = TRUE))
})

# Tests whether datalists can be downloaded and have correct variable names
test_that("Datalist DE can be downloaded and has correct variable names", {
  download_datalist(testthat::test_path("Datalist_d.xlsx"), language = "de")
  var_names <- names(read_data(testthat::test_path("Datalist_d.xlsx")))
  expect_true(all(var_names == names(datalist_example)))
})

test_that("Datalist FR can be downloaded and has correct variable names", {
  download_datalist(testthat::test_path("Datalist_f.xlsx"), language = "fr")
  var_names <- names(read_data(testthat::test_path("Datalist_f.xlsx")))
  expect_true(all(var_names == names(datalist_example)))
})

test_that("Datalist IT can be downloaded and has correct variable names", {
  download_datalist(testthat::test_path("Datalist_i.xlsx"), language = "it")
  var_names <- names(read_data(testthat::test_path("Datalist_i.xlsx")))
  expect_true(all(var_names == names(datalist_example)))
})

test_that("Datalist EN can be downloaded and has correct variable names", {
  download_datalist(testthat::test_path("Datalist_e.xlsx"), language = "en")
  var_names <- names(read_data(testthat::test_path("Datalist_e.xlsx")))
  expect_true(all(var_names == names(datalist_example)))
})
