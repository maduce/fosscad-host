<?php
$filename = '../'.$_REQUEST['f'];

// Override PHP.INI memory limit
if(is_numeric($_GET['ml'])) ini_set("memory_limit", intval($_GET['ml'])."M");

if(!file_exists($filename)) die('Error: File does not exist');
if(!function_exists('imagecreatetruecolor')) die('Error: GD2 not installed / configured');

$fn_array = explode('.', $filename); 
$type = strtolower(end($fn_array));

if ($type == 'jpg' || $type == 'jpeg') $img = @imagecreatefromjpeg($filename);
elseif ($type == 'png') $img = @imagecreatefrompng($filename);
elseif ($type == 'gif')  {
	if(!function_exists('imagecreatefromgif')) die('Error: Your version of GD does not support GIFs');
	$img = @imagecreatefromgif($filename);
}
else die("Error: Image type not supported");

$x = imagesx($img);
$y = imagesy($img);

$width = 150;
$height = round(($y/$x) * $width);

$tmpimage = imagecreatetruecolor($width, $height);
imagecopyresampled($tmpimage, $img, 0, 0, 0, 0, $width, $height, $x, $y);
imagedestroy($img);
$img = $tmpimage;

if ($type == 'jpg' || $type == 'jpeg') {
	header("Content-type: image/jpeg");
	imagejpeg($img, '', 65);
} 
elseif ($type == 'png') {
	header("Content-type: image/png");
	imagetruecolortopalette($img, false, 128);
	imagepng($img);
} 
elseif ($type == 'gif') {
	header("Content-type: image/png");
	imagetruecolortopalette($img, false, 128);
	imagepng($img);
}
?>