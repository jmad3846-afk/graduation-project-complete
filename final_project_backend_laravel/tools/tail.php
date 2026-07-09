<?php
$content = file_get_contents('e2e_stdout.txt');
echo substr($content, -3000);
