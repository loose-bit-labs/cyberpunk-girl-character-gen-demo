#!/usr/bin/env python
#############################################################################

import argparse

import xml.etree.ElementTree as ET
from datetime import timedelta

##
 #
 # Extract the start timestamp for all resource on each playlist of a Shotcut MLT file
 #
 # % ./timeline-for-shotcut.py -f nice.mlt -b |head
 # Timeline: main_bin
 # - 0:00:00.000000 clip-01-intro.mkv
 # - 0:00:28.920000 clip-sd-step1-20.mp4
 # - 0:00:39.360000 clip-sd-step2-20.mp4
 # - 0:00:49.320000 clip-02-character-00001.mkv
 # - 0:01:01.840000 clip-03-cleandup.mkv
 # - 0:21:50.280000 clip-04-mixamo-best.mkv
 # - 0:35:42.840000 clip-05-mixamo-short.mkv
 # - 0:37:32.960000 clip-06-blender-nla.mkv
 # - 0:37:57.280000 clip-07-godot.mkv
 #
 ##
class TimelineForShotcut:
    def __init__(self):
        self.parser = argparse.ArgumentParser(description="Extract the start timestamp for all resource on each playlist of a Shotcut MLT file")
        self.parser.add_argument("-f", "--file", type=str)
        self.parser.add_argument("-b", "--basename", action="store_true")
        self.parser.add_argument("-s", "--srt", action="store_true")

    def main(self):
        args = self.parser.parse_args()

        mlt_file = args.file
        timelines = self.extract_timestamps(mlt_file)

        # Output the results for each timeline
        for timeline_name, timestamp_data in timelines.items():
            print(f'Timeline: {timeline_name}')
            index = 0
            for resource, start, end in timestamp_data:
                index = index + 1
                if resource is None:
                    continue
                if -1 == start.find('.'):
                    start = start + '.000000'
                if -1 == end.find('.'):
                    end = end + '.000000'
                if args.basename:
                    resource = resource[resource.rfind('/') + 1:]
                if args.srt:
                    start = start.replace('.', ',')
                    end   = end.replace('.', ',')
                    print(f'{index}\n{start} --> {end}\n{resource}\n')
                else:
                    print(f'- {start:14} -> {end:14} : {resource}')
                #print(f'Resource: {resource}, Start: {start}')
            print()  # Blank line between timelines

    def parse_timecode(self, timecode):
        """Convert a timecode string to a timedelta object."""
        h, m, s = map(float, timecode.split(':'))
        return timedelta(hours=int(h), minutes=int(m), seconds=s)

    def get_resource(self, root, producer_id):
        """Look up the resource path associated with a given producer ID."""
        search = f".//*[@id='{producer_id}']"
        actual_producer = root.find(search)
        if actual_producer is not None:
            resource = actual_producer.find(f".//property[@name='resource']")
            if resource is not None:
                return resource.text
        return None

    def extract_timestamps(self, mlt_file):
        tree = ET.parse(mlt_file)
        root = tree.getroot()
        
        timelines = {}
        
        for playlist in root.findall('.//playlist'):
            timeline_name = playlist.get('id')

            # not sure why can't just pull this by name
            # timeline_alias = playlist.find(".//property[name='shotcut:name']")
            for property in playlist.findall(".//property"):
                name = property.get('name')
                if name == 'shotcut:name':
                    timeline_name = f'{timeline_name} ({property.text})'
                    break

            cumulative_time = timedelta()
            timestamps = []

            for element in playlist:
                if element.tag == 'entry':
                    start_time = cumulative_time
                    in_time = self.parse_timecode(element.get('in'))
                    out_time = self.parse_timecode(element.get('out'))
                    duration = out_time - in_time
                    cumulative_time += duration

                    producer_id = element.get('producer')
                    resource = self.get_resource(root, producer_id)
                    timestamps.append((resource, str(start_time), str(cumulative_time)))
                
                elif element.tag == 'blank':
                    blank_duration = self.parse_timecode(element.get('length'))
                    cumulative_time += blank_duration

            timelines[timeline_name] = timestamps

        return timelines

# end of class TimelineForShotcut

if __name__ == "__main__":
    TimelineForShotcut().main()

# EOF
#############################################################################
