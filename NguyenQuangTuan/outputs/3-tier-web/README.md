# Develop a simple 3-tier web application

## 1. Description

3-tier web application using 3 services: web, api, and database based on the MERN (MongoDB, ExpressJs, ReactJs, NodeJs) Stack.

<div align="center">
  <img width="600" src="./assets/images/mern.png" alt="gitflow">
</div>

<div align="center">
  <i><a href=https://www.boardinfinity.com/blog/mern-stack-what-is-it>
         MERN Stack
        </a></i>
</div>
<br>

Maintain the source code of api and web in 2 different repositories, each feature is a pull request. In both repositories, apply git flow to create main, release, and develop branches. When developing a new feature, checkout and create a pull request to the develop branch. From develop, it will be merged into release and then to main. Tags will be created from the main branch to mark deployment versions.

<div align="center">
  <img width="600" src="./assets/images/gitflow.png" alt="gitflow">
</div>

<div align="center">
  <i><a href=https://medium.com/@yanminthwin/understanding-github-flow-and-git-flow-957bc6e12220>
         Understanding GitHub Flow and Git Flow
        </a></i>
</div>
<br>

Commits sent up will follow a convention. Commit convention is a standardized way of writing commit messages during software development. It helps team members better understand the content of each commit and easily track the project's change history. In the 2 repositories `VDT-midterm-api` and `VDT-midterm-web`, Angular Conventional Commit will be used.

<div align="center">
  <img width="600" src="./assets/images/conventional-commit.png" alt="Angular Conventional Commit">
</div>

<div align="center">
  <i><a href=https://www.conventionalcommits.org/en/v1.0.0-beta.4>
         Angular Conventional Commit
        </a></i>
</div>
<br>

### 1.1 Web service

Develop the web service using the [ReactJS](https://react.dev/) library written in [TypeScript](https://www.typescriptlang.org/) and combined with a build tool with module bundler Rollup, which is [ViteJs](https://vitejs.dev/).

ReactJS is a popular JavaScript library for building user interfaces. Vite is a fast and modern build tool that speeds up development by providing a fast development environment and an efficient build system. TypeScript is an extension of JavaScript that provides static type checking and powerful development tools. Combining ReactJS, Vite, and TypeScript helps improve development performance and code quality.

<div align="center">
  <img width="600" src="./assets/images/reactjs-vite-typescript.png" alt="ReactJs + Vite + TypeScript">
</div>

<div align="center">
  <i> ReactJs + Vite + TypeScript</i>
</div>

### 1.2 Api service

Develop the api service using the [ExpressJs](https://expressjs.com/) framework of Nodejs written in TypeScript.

Express.js is a popular web framework for Node.js, allowing for quick and easy creation of web applications and APIs. TypeScript is an extension of JavaScript that provides static type checking and powerful development tools. Using TypeScript with Express.js helps improve code quality and project maintainability.

<div align="center">
  <img width="600" src="./assets/images/nodejs-expressjs-typescript.png" alt="Nodejs + ExpressJs + TypeScript">
</div>

<div align="center">
  <i>Nodejs + ExpressJs + TypeScript</i>
</div>

### 1.3 Database service

Develop the database service based on the MongoDB database.

MongoDB is an open-source NoSQL database that allows for flexible JSON document storage and querying. Designed for scalability and flexibility in storing unstructured data, MongoDB is a popular choice for fast and modern web applications.

<div align="center">
  <img width="600" src="./assets/images/mongodb.png" alt="Mongodb">
</div>
<div align="center">
  <i>MongoDB</i>
</div>

## 2. Output

- <b>Api repository</b>: [VDT-midterm-api](https://github.com/quangtuanitmo18/VDT-midterm-api)

  - Pull requests:
    - [Feature/api-crud-users](https://github.com/quangtuanitmo18/VDT-midterm-api/pull/1)
    - [Feature/dockerize-api-server](https://github.com/quangtuanitmo18/VDT-midterm-api/pull/2)
    - [Feature/test-api-crud-users](https://github.com/quangtuanitmo18/VDT-midterm-api/pull/3)
    - [Feature/pipeline-ci-cd](https://github.com/quangtuanitmo18/VDT-midterm-api/pull/4)

- <b>Web repository</b>: [VDT-midterm-web](https://github.com/quangtuanitmo18/VDT-midterm-web)
  - Pull requests:
    - [Feature/users-data-binding](https://github.com/quangtuanitmo18/VDT-midterm-web/pull/1)
    - [Feature/dockerize-client-server](https://github.com/quangtuanitmo18/VDT-midterm-web/pull/2)
    - [Feature/pipeline-ci-cd](https://github.com/quangtuanitmo18/VDT-midterm-web/pull/3)

<br>

#### Test Api on postman

<div align="center">
  <img width="600" src="./assets/images/api-get-list-users.png" alt="api-get-list-users">
</div>
<div align="center">
  <i>Api get list users</i>
</div>
<br>

<div align="center">
  <img width="600" src="./assets/images/api-get-user.png" alt="api-get-user">
</div>
<div align="center">
  <i>Api get user</i>
</div>
<br>

<div align="center">
  <img width="600" src="./assets/images/api-create-user.png" alt="Api create user">
</div>
<div align="center">
  <i>Api create user</i>
</div>
<br>

<div align="center">
  <img width="600" src="./assets/images/api-update-user.png" alt="Api update user">
</div>
<div align="center">
  <i>Api update user</i>
</div>
<br>

<div align="center">
  <img width="600" src="./assets/images/api-delete-user.png" alt="Api delete user">
</div>
<div align="center">
  <i>Api delete user</i>
</div>
<br>

#### Results when running test cases

<div align="center">
  <img width="600" src="./assets/images/result-test-cases.png" alt="Result of test cases">
</div>
<div align="center">
  <i>Result of test cases</i>
</div>
<br>

#### Results displayed on the browser

<div align="center">
  <img width="600" src="./assets/images/user-table.png" alt="user table">
</div>
<div align="center">
  <i>User list table</i>
</div>
<br>
