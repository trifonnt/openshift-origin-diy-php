openshift-diy-php
============================

This is a sample repository to get a custom PHP version running on [openshift](https://openshift.redhat.com).

It's a work in progress!

What's inside
-------------

The misc/install.sh script installs:

* [Apache HTTP server](http://projects.apache.org/projects/http_server.html)
* [PHP](http://php.net/)
* [XDebug](http://xdebug.org)

**Note** that different branches exists for ther respective PHP versions (WIP)

It configures apache to have the www folder as the document root. It also
uses the php.ini-development from the php archive and moves it into the
correct folder.

The script does not remove the source files, so you can easily recompile
Apache or PHP. Have a look at the shell script to see with which options
both were compiled the first time.

The misc/parse_templates.py script takes the template files from misc/templates and
replaces some variables with the actual folder pathes (because these
depend on the application, they cannot be hardcoded). It then copies
the file to the appropiate location.

Usage
-----

To get your custom PHP version working at OpenShift, you have to do the following:

1. Create a new Openshift "Do-It-Yourself" application.
2. Clone this repository.
    * ! Optionally you might want to change to a different branch to get a different PHP version.
3. Add a new remote "openshift" (You can find the URL to your git repository on the Openshift application page)
4. Run `git push --force "openshift" master:master`
5. SSH into your gear
6. `nohup $OPENSHIFT_REPO_DIR/misc/install.sh > $OPENSHIFT_DIY_LOG_DIR/install.log`
7. Wait (This may take at least an hour)
    If you want to see "what's going on, you may tail the log file and watch some shell movie ;)
    `nohup $OPENSHIFT_REPO_DIR/misc/install.sh > $OPENSHIFT_DIY_LOG_DIR/install.log &`
    `tail -f $OPENSHIFT_DIY_LOG_DIR/install.log`
8. Open http://appname-namespace.rhcloud.com/phpinfo.php to verify running
   apache
9. You can remove the misc content

Thanks
------

Thanks to the following people (ordered by name):

* [@marekjelen](https://github.com/marekjelen)
* [@venu](https://github.com/venu)
