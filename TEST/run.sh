#!/bin/sh
set -x
../slash --preview input_file.mp4 output_prefix_ 0 "??_lesson" 1.1 "*_summary" 2:2.2 "??_lesson" 3:3.3 "!??_summary" 4:4.4 "^^!!\!??_lesson" 1:59:59.999 "!\!??_summary" 2:1:1.001
../slash --preview input_file.mp4 output_prefix_ 0 "??_lesson" 1.1 "*_summary" 2:2.2
../slash --preview input_file.mp4 output_prefix_ 2:2.2 "@2??_lesson" 3:3.3 "!??_summary" 4:4.4
../slash --preview input_file.mp4 output_prefix_ 4:4.4 "@@04^^!!!\!??_lesson" 1:59:59.999 "!\!??_summary" 2:1:1.001
