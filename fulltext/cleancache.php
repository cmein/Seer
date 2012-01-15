<?php
// Full-Text RSS: Clear Cache
// Author: Keyvan Minoukadeh
// Copyright (c) 2011 Keyvan Minoukadeh
// License: AGPLv3

/*
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

// Usage
// -----
// Set up your scheduler (e.g. cron) to request this file periodically.
// Note: this file must not be named cleancache.php so please rename it.
// We ask you to do this to prevent others from initiating
// the cache cleanup process. It will not run if it's called cleancache.php.

error_reporting(E_ALL ^ E_NOTICE);
ini_set("display_errors", 1);
@set_time_limit(180);

// check file name
if (basename(__FILE__) == 'cleancache.php') die('cleancache.php must be renamed');

// set include path
set_include_path(realpath(dirname(__FILE__).'/libraries').PATH_SEPARATOR.get_include_path());

require_once(dirname(__FILE__).'/config.php');
if (file_exists(dirname(__FILE__).'/custom_config.php')) {
	require_once(dirname(__FILE__).'/custom_config.php');
}
if (!$options->caching) die('Caching is disabled');

// cache life in seconds
$cache_life = 30 * 60; // 30 minutes
foreach (glob($options->cache_dir.'/http-responses/*', GLOB_NOSORT) as $filename) {
    if (is_file($filename)) {
		$mtime = @filemtime($filename);
		if ($mtime && ((time() - $cache_life) > $mtime)) {
			//echo $filename."\n";
			@unlink($filename);
		}
	}
}

// cache life in seconds
$cache_life = 20 * 60; // 20 minutes
foreach (glob($options->cache_dir.'/rss/*', GLOB_NOSORT) as $filename) {
    if (is_file($filename)) {
		$mtime = @filemtime($filename);
		if ($mtime && ((time() - $cache_life) > $mtime)) {
			//echo $filename."\n";
			@unlink($filename);
		}
	}
}

// cache life in seconds
$cache_life = 20 * 60; // 20 minutes
foreach (glob($options->cache_dir.'/rss-with-key/*', GLOB_NOSORT) as $filename) {
    if (is_file($filename)) {
		$mtime = @filemtime($filename);
		if ($mtime && ((time() - $cache_life) > $mtime)) {
			//echo $filename."\n";
			@unlink($filename);
		}
	}
}

?>