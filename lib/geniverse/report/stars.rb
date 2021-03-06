require 'time'

module Geniverse
  module Report
    class Stars
      attr_accessor :class_name
      attr_accessor :all_classes

      def initialize(class_names)
        @class_names = class_names || []
        @all_classes = @class_names.include?("|ALL|") ? true : false
        @current_row = {:stars => 1, :posts => 1}

        @no_arguments_text = 'no arguments submitted yet'
        @time_format = '%Y-%m-%d %l:%M %p'
      end

      def caselogActivities
        json = File.read(File.join(File.dirname(__FILE__),'..','..','cases.js'))
        json.sub!(/.*?Lab.caselogData = \[/m, '[')
        json.sub!(/\];.*?call\(this\);.*/m, ']')
        json.gsub!(/([a-zA-Z0-9]+): ("|t|\[|\{)/) do |m|
          %!"#{$1}": #{$2}!
        end
        data = JSON.parse(json)
        acts = []
        data.each do |level|
          level["cases"].each do |kase|
            kase["challenges"].each do |act|
              acts << act if act = Activity.find_by_route(act['href'].sub(/^#/,''))
            end
          end
        end
        return acts
      end

      def run_report
        wb = Reports::Book.new
        stars_sheet = wb.create_worksheet :name => 'stars'
        journal_sheet = wb.create_worksheet :name => 'journal'

        @cols = {}
        headers = ['Username', 'Login', 'Class', 'Group #', 'Group member #']

        @current_row = {:stars => 1, :posts => 1}

        caselogActivities.each do |a|
          @cols[a.id] = headers.size
          headers << a.title
        end

        stars_sheet.row(0).concat headers
        journal_sheet.row(0).concat ['Username', 'Login', 'Class', 'Date/Time', 'Challenge', 'Claim', 'Evidence', 'URL', 'Reasoning']

        Geniverse::User.all.each do |u|
          next if u.class_name.nil? || u.class_name.empty?
          next unless @all_classes || @class_names.include?(u.class_name.strip)

          portal_user = ::User.find_by_login(u.username)
          next if portal_user && portal_user.portal_teacher

          process_stars(stars_sheet, u)
          process_posts(journal_sheet, u)
        end

        # sorter is handed row objects. Sort by Date/Time descending, Login ascending.
        journal_sort = ->(a,b) {
          return -1 if a[3] == 'Date/Time'
          return 1 if a[3] == @no_arguments_text
          time_a = a[3].is_a?(Time) ? a[3] : (Time.parse(a[3]) rescue Time.new(1980))
          time_b = b[3].is_a?(Time) ? b[3] : (Time.parse(b[3]) rescue Time.new(1980))
          time_comparison = time_b <=> time_a
          return time_comparison unless time_comparison == 0
          return a[1] <=> b[1]
        }
        journal_sheet.rows.sort!(&journal_sort)
        #journal_sheet.updated_from(0)
        #journal_sheet.format_dates!('MM-DD-YYYY HH:MM AM/PM')

        #wb.write stream_or_path
        return wb
      end

      def lookup_id_from_path(path)
        id = -1
        if path =~ /\/rails\/activities\/(\d+)/
          id = $1.to_i
        else
          # maybe it's a route: case1/challenge1
          a = Activity.find_by_route(path)
          id = a.id if a
        end
        return id
      end

      def process_stars(sheet, u)
        sheet.row(@current_row[:stars]).concat ["#{u.first_name} #{u.last_name}", u.username, u.class_name.strip, u.group_id, u.member_id]
        if md = u.metadata
          if (stars = md['stars']) && stars.is_a?(Hash)
            # sort so that rails ids will always come before route ids
            stars.keys.sort.each do |path|
              vals = stars[path]
              id = lookup_id_from_path(path)
              if col = @cols[id]
                realVals = vals.map{|v|
                  case v
                  when Hash
                    time = v['time']
                    if time.is_a?(String)
                      time = Time.parse(v['time']) rescue v['time']
                    end
                    t = time.respond_to?('strftime') ? time.strftime(@time_format) : time
                    "#{v['stars']} (#{t})"
                  else
                    v
                  end
                }
                if sheet.row(@current_row[:stars])[col] &&
                   sheet.row(@current_row[:stars])[col] != ""
                  sheet.row(@current_row[:stars])[col] = sheet.row(@current_row[:stars])[col].to_s + ","
                end
                sheet.row(@current_row[:stars])[col] ||= ""
                sheet.row(@current_row[:stars])[col] += realVals.join(',').to_s
              end
            end
          end
        end
        @current_row[:stars] += 1
      end

      # Columns are: ['Username', 'Login', 'Class', 'Date/Time', 'Challenge', 'Claim', 'Evidence', 'URL', 'Reasoning']
      def process_posts(sheet, user)
        common_row_data = ["#{user.first_name} #{user.last_name}", user.username, user.class_name.strip]
        if (md = user.metadata) && md.is_a?(Hash) && (posts = md['posts']) && posts.is_a?(Hash)
          # sort so that rails ids will always come before route ids
          posts.keys.sort.each do |path|
            vals = posts[path]
            id = lookup_id_from_path(path)
            if id != -1 && vals && vals.is_a?(Array) && !vals.empty?
              vals.each do |post|
                if post && post.is_a?(Hash) && (act = caselogActivities.detect{|a| a.id == id })
                  time = post['time']
                  if time.is_a?(String)
                    time = Time.parse(post['time']) rescue post['time']
                  end
                  t = time.respond_to?('strftime') ? time.strftime(@time_format) : time
                  sheet.row(@current_row[:posts]).concat(common_row_data + [t, act.title, post['claim'], post['evidence'], post['url'], post['reasoning']])

                  @current_row[:posts] += 1
                end
              end
            end
          end
        else
          sheet.row(@current_row[:posts]).concat(common_row_data + [@no_arguments_text])

          @current_row[:posts] += 1
        end
      end
    end
  end
end
