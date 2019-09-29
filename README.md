![](https://github.com/senselogic/SLASH/blob/master/LOGO/slash.png)

# Slash

FFmpeg-based video file splitter.

## Features

* Splits a video file into several sections by executing FFmpeg commands.
* Don't re-encode the streams, unless asked to do so.
* Maintains an increasing section index, which can be inserted in the section names.

## Installation

Install [FFmpeg](https://ffmpeg.org/download.html).

Install the [DMD 2 compiler](https://dlang.org/download.html) (choosing the MinGW setup option on Windows).

Build the executable with the following command line :

```bash
dmd -m64 slash.d
```

## Command line

```bash
slash [options] input_file.mp4 output_prefix_ HH:MM:SS.mmm first_section_name HH:MM:SS.mmm second_section_name ... HH:MM:SS.mmm last_section_name HH:MM:SS.mmm

```

### Options

```bash
--encode : re-encode audio and video streams
--preview : preview the ffmpeg commands without executing them
```

### Time formats

```bash
hours:minutes:seconds.milliseconds (1:2:3.456)
hours:minutes:seconds (1:2:3)
minutes:seconds.milliseconds (2:3.456)
minutes:seconds (2:3)
seconds.milliseconds (3.456)
seconds (3)
```

### Section name prefixes

```bash
* : put the previous section name
@@@ : assign the section index to the next 3 digits
@@ : assign the section index to the next 2 digits
@ : assign the section index to the next digit
! : decrease the section index
^ : increase the section index
\ : escape the next character
```

### Section name operators

```bash
??? : put the section index on 3 digits
?? : put the section index on 2 digits
? : put the section index
```

### Example

```bash
slash input_file.mp4 output_prefix_ 0 "??_lesson" 1.1 "*_summary" 2:2.2 "@2??_lesson" 3:3.3 "!??_summary" 4:4.4 "@@04^^!!!\!??_lesson" 1:59:59.999 "!\!??_summary" 2:1:1.001
```

Executes the following FFmpeg commands :

```bash
ffmpeg -y -ss 0:0:0 -i input_file.mp4 -to 0:0:1.1 -c:v copy -c:a copy output_prefix_01_lesson.mp4
ffmpeg -y -ss 0:0:1.1 -i input_file.mp4 -to 0:2:1.1 -c:v copy -c:a copy output_prefix_01_lesson_summary.mp4
ffmpeg -y -ss 0:2:2.2 -i input_file.mp4 -to 0:1:1.1 -c:v copy -c:a copy output_prefix_02_lesson.mp4
ffmpeg -y -ss 0:3:3.3 -i input_file.mp4 -to 0:1:1.1 -c:v copy -c:a copy output_prefix_02_summary.mp4
ffmpeg -y -ss 0:4:4.4 -i input_file.mp4 -to 1:55:55.599 -c:v copy -c:a copy output_prefix_!03_lesson.mp4
ffmpeg -y -ss 1:59:59.999 -i input_file.mp4 -to 0:1:1.002 -c:v copy -c:a copy output_prefix_!03_summary.mp4
```

## Version

1.0

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
