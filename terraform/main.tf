terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.39.0"
    }

    github = {
      source  = "hashicorp/github"
      version = ">= 6.6.0"
    }
  }
}

provider "google" {
  project = "<my project>"
}

data "github_repository_file" "verify-udf-file" {
  repository = "kamalaboulhosn/smtexperiments"
  branch     = "main"
  file       = "terraform/udfs/verifyId.js"
}

resource "google_pubsub_topic" "verified-topic" {
  name = "verified-topic"
  message_transforms {
    javascript_udf {
      function_name = regex(".+/(?P<file>\\w+)\\.js", "${data.github_repository_file.verify-udf-file.file}")["file"]
      code          = data.github_repository_file.verify-udf-file.content
    }
  }
}

variable "filter-udf-with-includes" {
  type = list(string)
  # The first file is the main function to be used in the UDF; the rest are
  # includes to be combined into the UDF.
  default = ["terraform/udfs/filterByRegion.js", "terraform/udfs/extractField.js"]
}

data "github_repository_file" "filter-udf-with-includes-files" {
  for_each   = toset(var.filter-udf-with-includes)
  repository = "kamalaboulhosn/smtexperiments"
  branch     = "main"
  file       = each.key
}

resource "google_pubsub_subscription" "filtered-by-location-sub" {
  name  = "filtered-by-location-sub"
  topic = google_pubsub_topic.verified-topic.name
  message_transforms {
    javascript_udf {
      function_name = regex(".+/(?P<file>\\w+)\\.js", "${var.filter-udf-with-includes[0]}")["file"]
      code          = join("\n", [for k, f in data.github_repository_file.filter-udf-with-includes-files : f.content])
    }
  }
}
