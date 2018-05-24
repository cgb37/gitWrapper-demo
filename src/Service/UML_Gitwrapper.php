<?php
namespace App\Service;

use GitWrapper\GitWrapper;
use GitWrapper\Event\GitLoggerListener;
use Monolog\Logger;
use Monolog\Handler\StreamHandler;


class UML_Gitwrapper {


	public function __construct() {
		$this->_gitWrapper = new GitWrapper();
		$this->_gitWrapper->setPrivateKey('/www-data/.ssh/id_rsa');


		$this->_gitWrapper->git('add src/Service/UML_Gitwrapper.php');
		$this->_gitWrapper->git('commit -m "wip testing push"');
		$this->_gitWrapper->git('push');

		// Log to a file named "git.log"
		$log = new Logger('git');
		$log->pushHandler(new StreamHandler('var/logs/git.log', Logger::DEBUG));

		// Instantiate the listener, add the logger to it, and register it.
		$listener = new GitLoggerListener($log);
		$this->_gitWrapper->addLoggerListener($listener);
		$this->_gitWrapper->git('status');
	}
}