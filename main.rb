#!/usr/bin/env ruby
#
# Given a GUI vim theme, find the closest supported terminal vim colour for
# each colour and output a version with the colours remapped to them.

require 'color_difference'

def main
  if ARGV.length != 1
    STDERR.puts "Usage: #{$0} <vim theme file to update>"
    return true
  end

  f = File.new(ARGV[0])
  f.each do |line|
    line.gsub!(/#(\S+)/) do |match|
      match = match[1..-1]
      find_closest(match)
    end
    puts line
  end

  return false
end

def find_closest(target_colour_hex)
  target_colour = hex_to_rgb(target_colour_hex)

  vim_colours = read_vim_colours

  closest = ''
  closest_diff = -1
  vim_colours.each do |vim_colour|
    diff = ColorDifference.cie2000(vim_colour[:rgb], target_colour)
    if closest_diff == -1 || diff < closest_diff
      closest_diff = diff
      closest = vim_colour[:vim]
    end
  end

  return closest
end

# Data is from https://vim.fandom.com/wiki/Xterm256_color_names_for_console_Vim
def read_vim_colours
  m = []
  f = File.new('vim-colours.txt')
  f.each do |line|
    matches = /ctermfg=(\d+) guifg=#(\S+)/.match(line)
    m << {
      hex: matches[2],
      rgb: hex_to_rgb(matches[2]),
      vim: matches[1],
    }
  end
  return m
end

# From https://gist.github.com/yous/6907d5ee01c237b9849ab005a13cf621
def hex_to_rgb(hex)
  rgb = hex.to_i(16)
  { r: rgb / 0x10000,
    g: (rgb / 0x100) % 0x100,
    b: rgb % 0x100 }
end

if main
  exit 0
end
exit 1
