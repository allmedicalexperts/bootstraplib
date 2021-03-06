version_resolve <- function(version) {
  version <- as.character(version)
  if (identical(version, "4-3")) {
    warning("Version '4-3' has been renamed to '4+3'. Please use '4+3' instead")
    version <- "4+3"
  }
  match.arg(version, c("4+3", "4", "3"))
}

get_exact_version <- function(version) {
  if (version %in% "3") version_bs3 else version_bs4
}

lib_file <- function(...) {
  files <- system_file("lib", ..., package = "bootstraplib")
  files_found <- files != ""
  if (all(files_found)) return(files)

  files_not_found <- file.path(...)[!files_found]
  stop(
    "bootstraplib file not found: '", files_not_found, "'",
    call. = FALSE
  )
}

# copy of shiny:::is_available
is_available <- function(package, version = NULL) {
  installed <- nzchar(system.file(package = package))
  if (is.null(version)) {
    return(installed)
  }
  installed && isTRUE(utils::packageVersion(package) >= version)
}

is_shiny_app <- function() {
  # Make sure to not load shiny as a side-effect of calling this function.
  "shiny" %in% loadedNamespaces() && shiny::isRunning()
}

add_class <- function(x, y) {
  class(x) <- unique(c(y, oldClass(x)))
  x
}

is_string <- function(x) {
  is.character(x) && length(x) == 1
}

dropNulls <- function(x) {
  x[!vapply(x, is.null, FUN.VALUE=logical(1))]
}

names2 <- function(x) {
  names(x) %||% rep.int("", length(x))
}

"%||%" <- function(x, y) {
  if (is.null(x)) y else x
}

#' Rename a named list
#'
#' @param x a named list to be renamed
#' @param nms a named character vector defining the renaming
#' @noRd
#' @examples
#' rename2(list(a=1, b=3, c=4, a=2), b="z", f="w", a="y")
#' #> list(y = 1, z = 3, c = 4, y = 2)
rename2 <- function(x, ...) {
  defs <- list(...)
  matches <- intersect(names(x), names(defs))
  map <- match(names(x), names(defs))
  mapidxNA <- is.na(map)
  names(x)[!mapidxNA] <- defs[map[!mapidxNA]]
  x
}

# Calculate the yiq value, given the (0-255) red/green/blue values
color_yiq <- function(r, g, b) {
  ((r * 299) + (g * 587) + (b * 114)) / 1000
}

# Determine if the given (0-255) red/green/blue values represent a light color,
# relative to the given yiq threshold
color_yiq_islight <- function(r, g, b, threshold = 150) {
  color_yiq(r, g, b) >= threshold
}


# Wrapper around base::system.file. In base::system.file, the package directory
# lookup is a bit slow. This caches the package directory, so it is much faster.
system_file <- local({
  package_dir_cache <- character()

  function(..., package = "base") {
    if (!is.null(names(list(...)))) {
      stop("All arguments other than `package` must be unnamed.")
    }

    if (package %in% names(package_dir_cache)) {
      package_dir <- package_dir_cache[[package]]
    } else {
      package_dir <- system.file(package = package)
      package_dir_cache[[package]] <<- package_dir
    }

    file.path(package_dir, ...)
  }
})
