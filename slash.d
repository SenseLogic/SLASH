/*
    This file is part of the Slash distribution.

    https://github.com/senselogic/SLASH

    Copyright (C) 2017 Eric Pelzer (ecstatic.coder@gmail.com)

    Slash is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3.

    Slash is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Slash.  If not, see <http://www.gnu.org/licenses/>.
*/

// -- IMPORTS

import core.stdc.stdlib : exit;
import std.conv;
import std.process;
import std.stdio;
import std.string;

// -- VARIABLES

bool
    PreviewOptionIsEnabled,
    EncodeOptionIsEnabled;
string
    InputFilePath,
    OutputFilePathPrefix;
string[]
    SectionNameArray,
    SectionTimeArray;

// -- FUNCTIONS

void PrintError(
    string message
    )
{
    writeln( "*** ERROR : ", message );
}

// ~~

void Abort(
    string message
    )
{
    PrintError( message );

    exit( -1 );
}

// ~~

string GetLongTime(
    string time
    )
{
    while ( time.count( ':' ) < 2 )
    {
        time = "0:" ~ time;
    }

    return time;
}

// ~~

string GetDuration(
    string first_time,
    string post_time
    )
{
    double
        second_count;
    long
        hour_count,
        minute_count;
    string[]
        duration_section_array,
        first_time_section_array,
        post_time_section_array;

    first_time_section_array = first_time.GetLongTime().split( ':' );
    post_time_section_array = post_time.GetLongTime().split( ':' );

    hour_count
        = post_time_section_array[ 0 ].to!long()
          - first_time_section_array[ 0 ].to!long();

    minute_count
        = post_time_section_array[ 1 ].to!long()
          - first_time_section_array[ 1 ].to!long();

    second_count
        = post_time_section_array[ 2 ].to!double()
          - first_time_section_array[ 2 ].to!double();

    if ( minute_count < 0 )
    {
        minute_count += 60;
        --hour_count;
    }

    if ( second_count < 0 )
    {
        second_count += 60.0;
        --minute_count;
    }

    return
        hour_count.to!string()
        ~ ":"
        ~ minute_count.to!string()
        ~ ":"
        ~ second_count.to!string();
}

// ~~

void SplitVideoFile(
    )
{
    long
        output_section_index;
    string
        command,
        section_file_path,
        section_name,
        section_duration;

    section_name = "";
    output_section_index = 0;

    foreach ( section_index, section_time; SectionTimeArray[ 0 .. $ - 1 ] )
    {
        section_duration
            = GetDuration(
                  section_time,
                  SectionTimeArray[ section_index + 1 ]
                  );

        if ( SectionNameArray[ section_index ].startsWith( '*' ) )
        {
            section_name ~= SectionNameArray[ section_index ][ 1 .. $ ];
        }
        else
        {
            ++output_section_index;
            section_name = SectionNameArray[ section_index ];
        }

        if ( section_name.startsWith( "@@@" ) )
        {
            output_section_index = section_name[ 3 .. 6 ].to!long();
            section_name = section_name[ 6 .. $ ];
        }

        if ( section_name.startsWith( "@@" ) )
        {
            output_section_index = section_name[ 2 .. 4 ].to!long();
            section_name = section_name[ 4 .. $ ];
        }

        if ( section_name.startsWith( '@' ) )
        {
            output_section_index = section_name[ 1 .. 2 ].to!long();
            section_name = section_name[ 2 .. $ ];
        }

        while ( section_name.startsWith( '!' )
                || section_name.startsWith( '^' ) )
        {
            if ( section_name.startsWith( '!' ) )
            {
                --output_section_index;
            }
            else
            {
                ++output_section_index;
            }

            section_name = section_name[ 1 .. $ ];
        }

        if ( section_name.startsWith( '\\' ) )
        {
            section_name = section_name[ 1 .. $ ];
        }

        section_name = section_name.replace( "???", ( "000" ~ output_section_index.to!string() )[ $ - 3 .. $ ] );
        section_name = section_name.replace( "??", ( "00" ~ output_section_index.to!string() )[ $ - 2 .. $ ] );
        section_name = section_name.replace( "?", output_section_index.to!string() );

        section_file_path = OutputFilePathPrefix ~ section_name ~ ".mp4";

        command
            = "ffmpeg -y -ss "
              ~ section_time.GetLongTime()
              ~ " -i "
              ~ InputFilePath
              ~ " -to "
              ~ section_duration
              ~ ( EncodeOptionIsEnabled ? " " : " -c:v copy -c:a copy " )
              ~ section_file_path;

        writeln( command );

        if ( !PreviewOptionIsEnabled )
        {
            executeShell( command );
        }
    }
}

// ~~

void main(
    string[] argument_array
    )
{
    string
        option;

    EncodeOptionIsEnabled = false;
    PreviewOptionIsEnabled = false;

    argument_array = argument_array[ 1 .. $ ];

    while ( argument_array.length >= 1
            && argument_array[ 0 ].startsWith( "--" ) )
    {
        option = argument_array[ 0 ];

        argument_array = argument_array[ 1 .. $ ];

        if ( option == "--encode" )
        {
            EncodeOptionIsEnabled = true;
        }
        else if ( option == "--preview" )
        {
            PreviewOptionIsEnabled = true;
        }
        else
        {
            Abort( "Invalid option : " ~ option );
        }
    }

    if ( argument_array.length >= 5 )
    {
        foreach ( argument_index, argument; argument_array )
        {
            if ( argument_index == 0 )
            {
                InputFilePath = argument;
            }
            else if ( argument_index == 1 )
            {
                OutputFilePathPrefix = argument;
            }
            else if ( ( argument_index & 1 ) == 0 )
            {
                SectionTimeArray ~= argument;
            }
            else
            {
                SectionNameArray ~= argument;
            }
        }

        SplitVideoFile();
    }
    else
    {
        writeln( "Usage :" );
        writeln( "    slash [options] input_file.mp4 output_prefix_ HH:MM:SS.mmm first_section_name HH:MM:SS.mmm second_section_name ... HH:MM:SS.mmm last_section_name HH:MM:SS.mmm" );
        writeln( "Time formats :" );
        writeln( "    hours:minutes:seconds.milliseconds (1:2:3.456)" );
        writeln( "    hours:minutes:seconds (1:2:3)" );
        writeln( "    minutes:seconds.milliseconds (2:3.456)" );
        writeln( "    minutes:seconds (2:3)" );
        writeln( "    seconds.milliseconds (3.456)" );
        writeln( "    seconds (3)" );
        writeln( "Options :" );
        writeln( "  --encode" );
        writeln( "  --preview" );
        writeln( "Section name prefixes :" );
        writeln( "    *" );
        writeln( "    @@@ddd" );
        writeln( "    @@dd" );
        writeln( "    @d" );
        writeln( "    !" );
        writeln( "    ^" );
        writeln( "    \\c" );
        writeln( "Section name operators :" );
        writeln( "    ???" );
        writeln( "    ??" );
        writeln( "    ?" );
        writeln( "Examples :" );
        writeln( "    slash input_file.mp4 output_prefix_ 0 \"??_lesson\" 1.1 \"*_summary\" 2:2.2 \"@2??_lesson\" 3:3.3 \"!??_summary\" 4:4.4 \"@@04^^!!!\\!??_lesson\" 1:59:59.999 \"!\\!??_summary\" 2:1:1.001" );
        writeln( "    slash input_file.mp4 output_prefix_ 0 \"??_lesson\" 1.1 \"*_summary\" 2:2.2" );
        writeln( "    slash input_file.mp4 output_prefix_ 2:2.2 \"@2??_lesson\" 3:3.3 \"!??_summary\" 4:4.4" );
        writeln( "    slash input_file.mp4 output_prefix_ 4:4.4 \"@@04^^!!!\\!??_lesson\" 1:59:59.999 \"!\\!??_summary\" 2:1:1.001" );

        Abort( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
