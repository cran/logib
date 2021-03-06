#' Check a dataframe
#'
#' \code{check_data} checks a dataframe (as produced by
#' \code{\link{read_data}}).
#'
#' This function checks a dataframe (as produced by \code{read_data}
#' for correctness and consistency)
#'
#' @param data data.frame to be checked
#'
#' @return a data.frame with information concerning each incorrect data point
#' in the \code{data} data.frame
#'
#' @keywords internal
#'
check_data <- function(data) {
  # Build a dataframe which will contain all errors found in the data as well
  # as an index vector for the row names
  errors <- data.frame()
  idx <- rownames(data)

  # ----- Missing values check -------------------------------------------------
  # Check for missing values of all obligatory columns
  obligatory_columns <- c("personal_number", "age", "sex", "years_of_service",
                          "training", "professional_function", "skill_level",
                          "professional_position", "basic_wage", "population")
  for (col in obligatory_columns) {
    error_rows <- as.numeric(idx[is.na(data[, col])])
    errors <- rbind(errors,
                    build_errors(error_rows, data$personal_number[error_rows],
                                 rep(NA, length(error_rows)), col,
                                 paste0("Missing '", gsub("_", " ", col), "'"),
                                 1))
  }

  # ----- Correct values check -------------------------------------------------
  # Check for non-unique personal_number
  error_rows <- as.numeric(idx[duplicated(data$personal_number) |
                      duplicated(data$personal_number, fromLast = TRUE)])
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$personal_number[error_rows],
                               "personal_number", "Duplicate 'personal number'",
                               1))

  # Check for non-integer age
  error_rows <- as.numeric(idx[data$age != as.integer(data$age)])
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$age[error_rows], "age",
                               "'Age' is not a whole number", 1))
  # Check for age limits (>= 13, <= 100)
  error_rows <- as.numeric(idx[data$age < 13 | data$age > 100])
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$age[error_rows], "age",
                               "'Age' is not between 13 and 100", 1))
  # Check for plausible age limits (>= 15, <= 70)
  error_rows <- as.numeric(idx[data$age < 15 | data$age > 70])
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$age[error_rows], "age",
                               "'Age' is not between 15 and 70", 2))
  # Check for incorrect sex (neither F nor M)
  error_rows <- as.numeric(idx[!(data$sex %in% c("F", "M"))])
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$sex[error_rows], "sex",
                               "'Sex' is neither 'F' nor 'M'", 1))

  # Check for years of service limits (>= 0, <= 85)
  error_rows <- as.numeric(idx[data$years_of_service < 0 |
                                 data$years_of_service > 85])
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$years_of_service[error_rows],
                               "years_of_service",
                               "'Years of service' is not between 0 and 85", 1))
  # Check for plausible years of service limits (>= 0, <= 55)
  error_rows <- as.numeric(idx[data$years_of_service > 55 &
                                 data$years_of_service <= 85])
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$years_of_service[error_rows],
                               "years_of_service",
                               "'Years of service' is more than 55", 2))
  # Check for wrong training/education values
  error_rows <- as.numeric(idx[!(data$training %in% 1:8)])
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$training[error_rows],
                               "training", "'Training' is not between 1 and 8",
                               1))
  # Check for FTE limits (0 - 150% or 0 - 300 hours)
  error_rows <- idx[data$activity_rate > 150 | data$activity_rate < 0]
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$activity_rate[error_rows], "activity_rate",
                               "'Activity rate' is not between 0% and 150%", 1))
  error_rows <- idx[data$activity_rate > 100 & data$activity_rate <= 150]
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$activity_rate[error_rows], "activity_rate",
                               "'Activity rate' is above 100%", 2))
  error_rows <- idx[data$paid_hours > 300 | data$paid_hours < 0]
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$paid_hours[error_rows], "paid_hours",
                               "'Paid hours' is not between 0 and 300", 1))
  error_rows <- idx[data$paid_hours >= 220 & data$paid_hours <= 300]
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$paid_hours[error_rows], "paid_hours",
                               "'Paid hours' is more than 220", 2))
  # Check for non-positive basic wage
  error_rows <- as.numeric(idx[data$basic_wage < 0])
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$basic_wage[error_rows], "basic_wage",
                               "'Basic wage' is negative", 1))
  error_rows <- as.numeric(idx[data$basic_wage == 0 & (data$activity_rate > 0 |
                                                         data$paid_hours > 0)])
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$basic_wage[error_rows], "basic_wage",
                               "'Basic wage' is zero", 1))
  # Check for negative allowances
  error_rows <- as.numeric(idx[data$allowances < 0])
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$allowances[error_rows], "allowances",
                               "'Allowances' are negative", 1))
  # Check for negative 13th monthly wage
  error_rows <- as.numeric(idx[data$monthly_wage_13 < 0])
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$monthly_wage_13[error_rows],
                               "monthly_wage_13",
                               "'13th monthly wage' is negative", 1))
  # Tolerance level for rounding errors
  tol <- 0.1
  # Check for 13th monthly wage exceeding 25% of the basic wage
  error_rows <- as.numeric(idx[4 * data$monthly_wage_13 -
                                 data$basic_wage > tol])
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$monthly_wage_13[error_rows],
                               "monthly_wage_13",
                               paste0("'13th monthly wage' exceeds 25% of the ",
                                      "'basic wage'"), 1))
  # Check for 13th monthly wage less than 8.5% (1/12) of the basic wage
  error_rows <- as.numeric(idx[data$basic_wage -
                                 12 * data$monthly_wage_13 > tol])
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$monthly_wage_13[error_rows],
                               "monthly_wage_13",
                               paste0("'13th monthly wage' is less than 8.5% ",
                                      "(1/12) of the 'basic wage'"), 2))
  # Check for negative special payments
  error_rows <- as.numeric(idx[data$special_payments < 0])
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$special_payments[error_rows],
                               "special_payments",
                               "'Special payments' are negative", 1))
  # Check for weekly hours range (>= 1, <= 100)
  error_rows <- as.numeric(idx[data$weekly_hours < 1 | data$weekly_hours > 100])
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$weekly_hours[error_rows],
                               "weekly_hours",
                               "'Weekly hours' are not between 1 and 100", 1))
  # Check for plausible weekly hours range (>= 1, <= 50)
  error_rows <- as.numeric(idx[data$weekly_hours > 50])
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$weekly_hours[error_rows],
                               "weekly_hours", "'Weekly hours' are above 50",
                               2))
  # Check for wrong population values
  error_rows <- as.numeric(idx[!(data$population %in% 1:5)])
  errors <- rbind(errors,
                  build_errors(error_rows, data$personal_number[error_rows],
                               data$population[error_rows],
                               "population",
                               "'Population' is not between 1 and 5", 1))
  errors
}

#' Builds a dataframe of errors
#'
#' \code{build_errors} builds a dataframe of errors as used by the function
#' \code{check_data}.
#'
#' @param rows a vector of numbers representing the rows which contain an error
#' @param pers_id a vector of strings of the personal ID which contain an error
#' @param vals a vector of the erroneous values
#' @param description the description of the error occurring
#' @param column the name of the column containing the error
#' @param importance the importance of the error occurring
#'
#' @return a dataframe of errors with the columns \code{column},
#' \code{description}, \code{importance}
#'
#' @keywords internal
#'
build_errors <- function(rows, pers_id, vals, column, description, importance) {
  n_rows <- length(rows)
  if (n_rows == 0) return(NULL)
  data.frame(row = rows, pers_id = pers_id, value = vals,
             column = rep(column, n_rows),
             description = rep(description, n_rows),
             importance = rep(importance, n_rows))
}

#' Cleanup data errors
#'
#' \code{cleanup_errors} launches a step-by-step cleanup prompt which goes
#' over all incorrect rows found in the data (as discovered by
#' \code{check_data})
#'
#' @param data a dataframe of the original data, i.e. the data to which the
#' \code{errors} parameter refers to
#' @param errors a dataframe of errors as produced by \code{check_data} to be
#' cleaned up
#' @param ignore_plausibility_check a boolean indicating whether the user wants
#' to ignore implausible data. If \code{TRUE}, the implausible data is
#' interpreted as being correct.
#'
#' @return a dataframe of the original data with cleaned up errors
#'
#' @keywords internal
cleanup_errors <- function(data, errors, ignore_plausibility_check = FALSE) {
  if (ignore_plausibility_check) {
    errors <- errors[errors$importance == 1, ]
    if (nrow(errors) == 0) {
      return(data)
    }
  }
  # Begin with the cleanup
  error_rows <- unique(errors$row)
  message(length(error_rows), " erroneous rows found in the dataset, ",
          "beginning clean up...")
  # Iterate over each incorrect row and then over each incorrect column within
  # this row
  for (r in error_rows) {
    err <- errors[errors$row == r, ]
    pers_id <- unique(err$pers_id)
    message(rep("-", 80))
    message("The row #", r, " (personal ID: ", pers_id, ") has ", nrow(err),
            " invalid/implausible values.")
    for (i in 1:dim(err)[1]) {
      message("Error type: ", err$description[i])
      message(" ", ifelse(err$importance[i] == 2, "implausible", "    invalid"),
              " value: ", err$value)
      message("Enter the correct value: ")
      data[err$row, err$column] <- readline()
    }
  }
  data
}
