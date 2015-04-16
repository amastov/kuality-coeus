Kuality-Coeus: Test Automation
==============================

Overview
--------

This project consists of Cucumber-based test scripts for validating Kuali Coeus functionality

Requirements
------------

See the Gemfile for gem dependencies.

In order for the scripts to actually run successfully, you will need to add the following environment variables to your command line:

_URL_ - The server address, including the https: and the trailing backslash

_CONTEXT_ - Any context value that appears prior to the query string in the URL. Includes a trailing backslash

 _PORT_ - Typically 80 ... But include only if the URL includes a port number after the domain.

_BROWSER_ - The test browser you're going to want to use. Options are ff, chrome, safari... See the watir-webdriver documentation for further details.

_HEADLESS_ - Include only if you're running in headless mode. It can be set to any value.

_CAS_ - Include if there is a CAS login page. Can be set to any value.

_CAS_CONTEXT_ - Include only if CAS is defined. It's the context string for the CAS Login URL, and should include a trailing backslash.


Contribute to the Project
-------------------------

1. Fork the repository
2. Study the [TestFactory design pattern](https://github.com/aheward/TestFactory#design-pattern) and how to [write Cucumber Features and Scenarios well](https://github.com/cucumber/cucumber/wiki/tutorials-and-related-blog-posts).
3. Make a new branch to contain your work
4. Write a feature and associated scenarios, along with the underlying support code
5. Squash your commits
6. Send a pull request, with a concise description of your changes

Copyright 2015 The Kuali Foundation
-----------------------------------

	Licensed under the Educational Community License, Version 2.0 (the "License");
	you may	not use this file except in compliance with the License.
	You may obtain a copy of the License at

    http://www.osedu.org/licenses/ECL-2.0

	Unless required by applicable law or agreed to in writing,
	software distributed under the License is distributed on an "AS IS"
	BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
	or implied. See the License for the specific language governing
	permissions and limitations under the License.