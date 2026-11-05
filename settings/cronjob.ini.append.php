<?php /* #?ini charset="utf-8"?

# The cronjob parts of exp_doc (cronjobs/)
[CronjobSettings]
ExtensionDirectories[]=exp_doc

# exp_doc_feeds.php: reads the Modern front page's commit and forum feeds every run, so a page view never waits for
# them (their cache time, exphelp.ini [CommitFeedSettings] CacheTTL, is longer than the run interval)
[CronjobPart-frequent]
Scripts[]=exp_doc_feeds.php

*/ ?>
