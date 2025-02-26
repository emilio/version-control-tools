Test pushing with a try_task_config.json works

  $ cat >> $HGRCPATH << EOF
  > [extensions]
  > push-to-try = $TESTDIR/hgext/push-to-try
  > [push-to-try]
  > nodate = true
  > [defaults]
  > diff = --nodate
  > EOF

  $ hg init remote

  $ hg clone remote local
  updating to branch default
  0 files updated, 0 files merged, 0 files removed, 0 files unresolved

  $ cd local
  $ echo line1 > file1.txt
  $ echo line1 > file2.txt
  $ hg add file1.txt
  $ hg commit -m "file1.txt added"

First test push should fail
  $ echo line1 > try_task_config.json
  $ hg add try_task_config.json
  $ hg push-to-try -m "Add try_task_config.json" -s ../remote
  Error reading try_task_config.json: could not decode as JSON

Second test push should succeed
  $ echo '{ "key": "this just has to be valid json" }' > try_task_config.json
  $ hg push-to-try -m "Add try_task_config.json" -s ../remote
  Creating temporary commit for remote...
  A try_task_config.json
  ? file2.txt
  pushing to ../remote
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 2 changesets with 2 changes to 2 files
  push complete
  temporary commit removed, repository restored
  $ hg verify
  checking changesets
  checking manifests
  crosschecking files in changesets and manifests
  checking files
  1 files, 1 changesets, 1 total revisions (no-hg48 !)
  checked 1 changesets with 1 changes to 1 files (hg48 !)

Test try commit made it to our remote

  $ cd ../remote
  $ hg log
  changeset:   1:6b750ec7e52b
  tag:         tip
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     Add try_task_config.json
  
  changeset:   0:153ffc71bd76
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     file1.txt added
  
  $ hg up -r 1
  2 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg diff -r 0
  diff -r 153ffc71bd76 try_task_config.json
  --- /dev/null
  +++ b/try_task_config.json
  @@ -0,0 +1,1 @@
  +{ "key": "this just has to be valid json" }
