## Setup GitLab on the server (gitlab-server: 192.168.64.141)

Choose the appropriate GitLab version for the current operating system (ubuntu/focal 20.04)

<div align="center">
  <img width="600" src="../images/gitlab-ce-14.4.1-versions.png" alt="gitlab-ce_14.4.1">
</div>

<div align="center">
  <i>gitlab-ce_14.4.1</i>
</div>
<br>
<div align="center">
  <img width="600" src="../images/gitlab-ce-14.4.1-focal.png" alt="gitlab-ce_14.4.1-focal">
</div>

<div align="center">
  <i>gitlab-ce_14.4.1 focal</i>
</div>
<br>

### Install GitLab CE

To install [gitlab-ce_14.1.8-ce.0_arm64.deb](https://packages.gitlab.com/gitlab/gitlab-ce/packages/ubuntu/focal/gitlab-ce_14.1.8-ce.0_arm64.deb), follow these steps:

Run the command to install the repository `curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash`

Run the command to install GitLab `sudo apt-get install gitlab-ce=14.1.8-ce.0`

<div align="center">
  <img width="600" src="../images/gitlab-installed.png" alt="Successfully installed gitlab">
</div>

<div align="center">
  <i>Successfully installed gitlab
</i>
</div>
<br>

Next, access the GitLab config file `vi /etc/gitlab/gitlab.rb` and update the external_url to the current IP.

<div align="center">
  <img width="600" src="../images/gitlab-external-url.png" alt="Update external url of gitlab">
</div>

<div align="center">
  <i>Update external url of gitlab</i>
</div>
<br>

Then run the command `gitlab-ctl reconfigure` to update the config.

<div align="center">
  <img width="600" src="../images/gitlab-1.png" alt="">
</div>

<div align="center">
  <i>Gitlab</i>
</div>
<br>

To log in to GitLab, you need to get the root user's password.
Run the command `cat /etc/gitlab/initial_root_password` to get the root user's password.

<div align="center">
  <img width="600" src="../images/gitlab-password-user-root.png" alt="password user root">
</div>

<div align="center">
  <i>Root password</i>
</div>
<br>

Change the root user's password and create 2 additional users: `tuan-maintainer` and `tuan-developer`.
Create 2 repositories: `VDT-midterm-api` and `VDT-midterm-web` and add the above 2 users to them.

<div align="center">
  <img width="600" src="../images/gitlab-add-users-to-repo-api.png" alt="">
</div>

<div align="center">
  <i>Add user to repository VDT-midterm-api</i>
</div>
<br>

<div align="center">
  <img width="600" src="../images/gitlab-add-users-to-repo-web.png" alt="">
</div>

<div align="center">
  <i>Add user to repository VDT-midterm-web</i>
</div>
<br>

In both repositories, create the `main`, `release`, and `develop` branches. When developing a new feature, checkout and create a merge request to the develop branch. From develop, it will be merged into release and then to main. Tags will be created from the main branch to mark deployment versions.

<div align="center">
  <img width="600" src="../images/gitlab-branches.png" alt="">
</div>

<div align="center">
  <i>branches</i>
</div>
<br>

Next, set up protected branches to ensure only maintainers have the right to push and merge MRs on the `main` and `release` branches.

<div align="center">
  <img width="600" src="../images/gitlab-protected-branch.png" alt="">
</div>

<div align="center">
  <i>Protected branch</i>
</div>
<br>

### Create user access token on GitLab server

To connect GitLab with Jenkins and SonarQube, create an access token. The access token must be created from a user with admin rights on GitLab.

<div align="center">
  <img width="800" src="../images/gitlab-personal-at-create.png" alt="Personal gitlab access token">
</div>
<div align="center">
  <img width="800" src="../images/gitlab-personal-at.png" alt="Personal gitlab access token">
</div>

<div align="center">
  <i>Personal gitlab access token</i>
</div>
<br>

### Create webhook to trigger pipeline in Jenkins

Set up the network to allow requests from web hooks and system hooks to the local network.
In settings `Admin Area -> Settings -> Network -> Outbound requests`

<div align="center">
  <img width="800" src="../images/gitlab-network-setting.png" alt="Network setting">
</div>
<div align="center">
  <i>Network setting</i>
</div>
<br>

Steps to perform with the `VDT-midterm-api` repository, do the same for `VDT-midterm-web`.

In the project, select `Settings -> Webhooks` and configure as follows:
`URL: http://<jenkins account>:<jenkins account token>@<jenkins address>/project/<jenkins project name>`

The webhook for `VDT-midterm-api` will have the URL: `http://jenkins-admin:1197fee3ac6455760068658062a4cbda6a@192.168.64.140:8080/project/pipeline-vdt-midterm-api`

<div align="center">
  <img width="800" src="../images/gitlab-webhook-1.png" alt="Network setting">
</div>
<br>
<div align="center">
  <img width="800" src="../images/gitlab-webhook-api.png" alt="Network setting">
</div>

Perform the same steps with the `VDT-midterm-web` repository.
The webhook for `VDT-midterm-web` will have the URL: `http://jenkins-admin:1197fee3ac6455760068658062a4cbda6a@192.168.64.140:8080/project/pipeline-vdt-midterm-web`

<div align="center">
  <img width="800" src="../images/gitlab-webhook-web.png" alt="Network setting">
</div>
