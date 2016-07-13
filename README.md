# WikiLinkValidator - Validate URL links in your wiki.
A python tool, designed for validating URLs as part of your wiki content, that is managed in a git repository.
<p align="center"><img src ="/images/Introducing.gif" /></p>

## Description
One of the most annoying things you might encounter while going over a wiki page, is to find out a link in it redirects you to a missing page (404).

Wiki-Validator uses a python script that scans all the files matching a pre-defined prefix,
and searches, using regex, for a specific pattern in the text that contains a link.
Once a link has been found it validate it and print an appropriate log.

## SETUP
* Make sure <i>python</i> and <i>git</i> are installed on your env.
* Other packages that should be installed: python-futures
* Clone the wiki git repo you want to scan, as so : `git clone git@github.com:{any wiki project}.git`  
  For example, this is how to clone ovirt-site:  
  ``` 
  git clone git@github.com:oVirt/ovirt-site.git
  ```
* Once your wiki project is cloned, set the home directory at conf/[wiki.conf](/conf/wiki.conf):  
  ```
  HOME_DIR = '/your_git_repo_location/'
  ```

* If you also want to add the ability to send a mail to the author which introduced that rot link, set the SEND_MAIL option to true in /conf/[wiki.conf](/conf/wiki.conf):
  ```
  SEND_MAIL = 'True'
  ```

## USAGE
After all is configured, run [wiki-links-validity.py](/wiki-links-validity.py) from the project home folder:
```
./wiki-links-validity.py`
```

Once the utility will encounter a rot link, it will check the git repo (Configured at HOME_DIR in /conf/[wiki.conf](/conf/wiki.conf)) for the first appearance of the URL using `git log --reverse`, and fetch the commiter email, username and the commit hashcode.

If SEND_MAIL option was set to true, an email example will be presented, asking if you confirm sending this email to the user:
<p align="center"><img src ="/images/mail_question.png" /></p>

Once the user will answer 'yes' or 'no', the script will present the next rot link it founds until it finishes.

While the script is running, a report is being generated containning all the rot links' details:
<p align="center"><img src ="/images/rot_links_report.png" /></p>

The report should be located in the home folder under the name rot_links.log (The report location can be confgured at  ROT_LINKS_LOG at /conf/[wiki.conf](/conf/wiki.conf)


## Other Useful Configuration Values

#### Configure the location of your rot links report
Once the util is running a report of all the rot links in the git repo will be published in a log file configured in  /conf/[wiki.conf](/conf/wiki.conf):
```
ROT_LINKS_LOG=rot_links.log
```

#### Whitelist URLs
Some URLs are used in the wiki to reflect an example or an internal link (like localhost).
Those types of URLs can be configured in the URL whitelist so those can be steped over and avoid validation.
The whitelist values are being checked against every link found in the git repo files, and if one link contains part of the string in the white list a proper message will be logged and this link will not be validated.
```
URL_WHITELIST = yourhost.example.com,localhost
```

#### File prefix to scan
The prefix of files to scan in the git repo for http links:
```
FILE_PREFIX=*.html.md
```

#### List of invalid http return codes.
All the http return codes which reflect an invalid http page:
```
INVALID_HTTP_CODES
```

#### HTTP regex pattern
The regex which is being used for http pattern:
```
HTTP_PATTERN
```

Second HTTP_PATTERN regex to double check the URL link:
```
HTTP_PATTERN2
```

#### Log file
Location of the log file:
```
DEBUG_LOG = 'links.log'
```

#### Mail configuration
The subject of the email, sent to the author, can be manipulated at conf/[mail.conf](/conf/mail.conf):
```
SUBJECT=Broken http link has been found in wiki page
```

The rest of the configuration can be found at conf/[mail.conf](/conf/mail.conf):

## Troubleshoot

If the script fails to run, please check the logs (log location should be configured in DEBUG_LOG at conf/[wiki.conf](/conf/wiki.conf):

## Contact

Please feel free to contact Maor Lipchuk (mlipchuk@redhat.com) or Daniel Erez (derez@redhat.com) on any question
