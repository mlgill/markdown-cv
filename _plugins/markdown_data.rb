# frozen_string_literal: true

# Plugin to parse markdown files from mlgill.github.io into structured data
# This allows patents.md, presentations.md, and about.md to be used without conversion

module MarkdownData
  class Generator < Jekyll::Generator
    safe true
    priority :high

    # Path to the source website repo (relative to markdown-cv)
    SOURCE_REPO = '../mlgill.github.io'

    def generate(site)
      source_path = File.expand_path(SOURCE_REPO, site.source)

      # Parse each markdown file into site.data
      site.data['patents'] = parse_patents(source_path)
      site.data['presentations'] = parse_presentations(source_path)
      site.data['bio'] = parse_about(source_path)

      Jekyll.logger.info "MarkdownData:", "Loaded #{site.data['patents'].sum { |y| y['entries'].size }} patents"
      Jekyll.logger.info "MarkdownData:", "Loaded #{site.data['presentations'].sum { |y| y['entries'].size }} presentations"
      Jekyll.logger.info "MarkdownData:", "Loaded bio data"
    end

    private

    # Parse patents.md into structured data
    # Returns array of { year: "2024", entries: [...] }
    def parse_patents(source_path)
      file = File.join(source_path, '_pages', 'patents.md')
      return [] unless File.exist?(file)

      content = File.read(file)
      parse_year_entries(content) do |lines|
        # Patent entry format:
        # **Title**
        # <br>Authors
        # <br>Patent info
        title = lines[0]&.gsub(/^\*\*|\*\*$/, '') || ''
        authors = clean_html(lines[1]) || ''
        details = clean_html(lines[2]) || ''

        {
          'title' => title,
          'authors' => authors,
          'details' => details
        }
      end
    end

    # Parse presentations.md into structured data
    def parse_presentations(source_path)
      file = File.join(source_path, '_pages', 'presentations.md')
      return [] unless File.exist?(file)

      content = File.read(file)
      parse_year_entries(content) do |lines|
        # Presentation entry format:
        # **Title**
        # <br>*Venue* (optional, may have authors before)
        # <br>Details (type, date, location)
        # <br>Links (optional)
        title = lines[0]&.gsub(/^\*\*|\*\*$/, '') || ''

        # Find venue (wrapped in *italics*) and other details
        venue = ''
        authors = ''
        details = ''
        links_html = ''
        links = {}

        lines[1..-1]&.each do |line|
          clean_line = clean_html(line)
          if line.include?('<a href')
            # Fix relative URLs to be absolute
            links_html = line.gsub(/^<br>/, '').gsub('href="/', 'href="https://mlgill.github.io/')
            # Extract URLs for each link type
            %w[slides video abstract program code thesis].each do |link_type|
              if line.include?("btn-#{link_type}")
                if match = line.match(/href="([^"]+)"[^>]*class="[^"]*btn-#{link_type}/)
                  url = match[1]
                  links[link_type] = url.start_with?('/') ? "https://mlgill.github.io#{url}" : url
                end
              end
            end
          elsif clean_line =~ /^\*.*\*$/
            # Venue in italics
            venue = clean_line.gsub(/^\*|\*$/, '')
          elsif clean_line =~ /^(Invited|Selected|Expo|Panel|\d{4},)/
            details = clean_line
          elsif clean_line.present? && venue.empty?
            # Could be authors or venue
            if clean_line.include?(' and ') || clean_line =~ /^[A-Z][a-z]+,/
              authors = clean_line
            else
              venue = clean_line.gsub(/^\*|\*$/, '')
            end
          elsif clean_line.present?
            details = clean_line if details.empty?
          end
        end

        {
          'title' => title,
          'venue' => venue,
          'authors' => authors,
          'details' => details,
          'links_html' => links_html,
          'links' => links
        }
      end
    end

    # Parse about.md for bio information
    def parse_about(source_path)
      file = File.join(source_path, '_pages', 'about.md')
      return {} unless File.exist?(file)

      content = File.read(file)

      # Extract YAML frontmatter
      if content =~ /\A---\s*\n(.*?)\n---\s*\n(.*)/m
        frontmatter = YAML.safe_load($1) || {}
        body = $2.strip
      else
        frontmatter = {}
        body = content
      end

      {
        'name' => 'Michelle Lynn Gill',
        'title' => frontmatter['subtitle']&.gsub(/<[^>]+>/, '') || '',
        'title_html' => frontmatter['subtitle'] || '',
        'bio' => body,
        'specialized_in' => 'Deep learning, computational biology, drug discovery, benchmarking',
        'research_interests' => 'Virtual cell models, proteomics, NMR spectroscopy, enzyme dynamics'
      }
    end

    # Generic parser for year-grouped markdown entries
    def parse_year_entries(content)
      # Remove YAML frontmatter
      content = content.sub(/\A---.*?---\s*/m, '')

      results = []
      current_year = nil
      current_entries = []
      current_entry_lines = []

      content.each_line do |line|
        line = line.strip

        if line =~ /^##\s*(\d{4})\s*$/
          # New year header
          if current_year && !current_entry_lines.empty?
            current_entries << yield(current_entry_lines)
          end
          if current_year
            results << { 'year' => current_year, 'entries' => current_entries }
          end
          current_year = $1
          current_entries = []
          current_entry_lines = []
        elsif line =~ /^\*\*.*\*\*$/
          # New entry (title in bold)
          if !current_entry_lines.empty?
            current_entries << yield(current_entry_lines)
          end
          current_entry_lines = [line]
        elsif line =~ /^<br>/ || (line.present? && !current_entry_lines.empty?)
          # Continuation of current entry
          current_entry_lines << line unless line.empty?
        end
      end

      # Don't forget the last entry and year
      if !current_entry_lines.empty?
        current_entries << yield(current_entry_lines)
      end
      if current_year
        results << { 'year' => current_year, 'entries' => current_entries }
      end

      results
    end

    # Remove HTML tags and <br> prefixes
    def clean_html(text)
      return '' if text.nil?
      text.gsub(/^<br>/, '').gsub(/<[^>]+>/, '').strip
    end
  end
end

# Add present? method to String if not available
class String
  def present?
    !nil? && !empty?
  end
end
