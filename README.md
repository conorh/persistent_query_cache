# Persistent Query Cache

This plugin enhances the ActiveRecord Query Cache to be persistent across requests for simple queries. It persists query results into the Rails::Cache. See the description section below for more detaila.

The inspiration for this plugin and some of the basic code comes from Fernando Blat's fork of the memcache query cache <http://github.com/ferblape/query_memcached>.

## Install

In your gemfile

    gem 'persistent_query_cache'

In the models where you want to enable the persistent query cache

    class User < ActiveRecord::Base
      enable_persistent_query_cache

## Requirements

  - Rails >= 3.x

## Description and Usage Notes

This plugin enhances the ActiveRecord Query Cache to be persistent across requests for simple queries. It persists query results into the Rails::Cache. Currently it only persists queries of the form 'SELECT * FROM one_table WHERE some_id = 1231'.

When the persistent query cache is active and working you should see log lines like this when there is a cache hit:

    Persistent Cache (2.3ms)  SELECT `users`.* FROM `users` WHERE `users`.`id` = 434 LIMIT 1

To expire the records in the Cache after_save/after_destroy hooks are added. If the after_save or after_destroy hooks are skipped in any way (update_all, manual changes etc.) then the records will not be expired from the cache!

Copyright (c) 2012 [Conor Hunt](http://www.squaremill.com), released under the MIT license