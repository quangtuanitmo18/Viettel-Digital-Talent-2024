# Midterm Project for the VDT 2024 Cloud Program

## Develop a Simple 3-tier Web Application (3 Points)

**Requirements:**

- Develop a web application with the following functionalities (0.5 Points):

  - Display a list of students participating in the VDT2024 program in a table with the following details: Full Name, Gender, School.
  - Allow viewing details, adding, deleting, and updating student information.

- Design the system with three services (1 Point):
  - **web**: Frontend interface; language and framework of your choice.
  - **api**: RESTful API written in a programming language of your choice, featuring the following functions: list, get, create, update, delete.
  - **db**: SQL or NoSQL database to store student information.
- Write unit tests for the API functionalities, ensuring at least one testcase per API (0.5 Points).

- Maintain the source code of the API and web services in two separate repositories, with each feature submitted as a Pull Request (1 Point).

**Output:**

- Screenshots showing the achieved results.
- Source code for each service (GitHub link).

**Output:** [Output 3-tier web application](./outputs/3-tier-web/README.md)

## Deploy the Web Application Using DevOps Tools & Practices (5 Points)

#### 1. Containerization (2 Points)

**Requirements:**

- Write a Dockerfile in each repository to package the services into container images (1 Point).
- Ensure that the images are optimized for build time and size, leveraging techniques such as layer-caching, optimized RUN instructions, multi-stage builds, etc. (1 Point).

**Output:**

- Dockerfile for each service.
- Output of the build commands and docker history information for each image.

#### 2. Continuous Integration (1.5 Points)

**Requirements:**

- Automatically run unit tests when a Pull Request is created targeting the main branch (0.5 Points).
- Automatically run unit tests when commits are pushed to any branch (1 Point).

**Output:**

- CI tool setup file.
- Output log of the CI pipeline.
- Other demo screenshots.

#### 3. Automation (1.5 Points)

**Requirements:**

- Write Ansible playbooks to deploy the Docker images for the web, api, and db services, with each service configured as a separate role (0.5 Point).
- Allow configuration customization for each service via variables in each role (0.5 Point).
- Enable deployment of services on different hosts using an inventory file (0.5 Point).

**Output:**

- GitHub source code link for the Ansible playbooks.

**Output:** [Deploy web application using DevOps tools & practices](./outputs/devops/README.md)

## In-depth Research on a Topic or Concept from the Studied Subjects (2 Points)

**Requirements:**

- Write about any topic related to the subjects studied.

**Output:**

- A report file included in the Pull Request to the common repository.

**Output:** [DevSecOps](./outputs/research-topic/README.md)
