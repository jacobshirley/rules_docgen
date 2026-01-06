# Swagger/OpenAPI Example

This directory contains an OpenAPI 3.0 specification file that demonstrates rich API documentation suitable for use with SwaggerUI.
We then run Bazel actions to run the docgen tool and stitch into the parent repository's documentation site.

## Files

- `openapi.yaml` - Complete OpenAPI 3.0 specification for a Task Management API

## Features Demonstrated

The OpenAPI specification includes:

- **Comprehensive API Documentation**: Rich descriptions for all endpoints, parameters, and schemas
- **Multiple Endpoints**: CRUD operations for tasks, projects, and users
- **Request/Response Examples**: Multiple examples for different use cases
- **Detailed Schemas**: Well-documented data models with validation rules
- **Error Responses**: Standardized error response formats
- **Authentication**: Bearer token authentication scheme
- **Pagination**: Pagination support for list endpoints
- **Filtering & Sorting**: Query parameters for filtering and sorting results

## Viewing with SwaggerUI

Run `bazel run mkdocs.serve`

Then open http://localhost:8080

## API Overview

The Task Management API provides:

- **Tasks**: Create, read, update, and delete tasks with status, priority, assignments, and due dates
- **Projects**: Organize tasks into projects
- **Users**: Manage users who can be assigned to tasks

All endpoints require Bearer token authentication and return JSON responses.
