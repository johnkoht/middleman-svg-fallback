require 'rake'
module Middleman
  module SVGFallback
    class << self
      def registered(app, options={})

        options[:inkscape_bin] ||= 'inkscape'

        app.after_configuration do

          dir = File.join(app.root, build_dir, images_dir)
          prefix = build_dir + File::SEPARATOR

          after_build do |builder|
            files = FileList["#{dir}/**/*.svg*"]

            files.each do |file|
              # make sure we have both an svg and an svgz version
              basename = File.expand_path(file.sub(/\.svgz?$/,''))

              unless File.exists? "#{basename}.svg"
                `gunzip --to-stdout --suffix .svgz  #{basename}.svgz > #{basename}.svg`
                builder.say_status :svg, "#{basename}.svg"
              end
              unless File.exists? "#{basename}.svgz"
                `gzip --to-stdout #{basename}.svg > #{basename}.svgz`
                builder.say_status :svgz, "#{basename}.svgz"
              end

              # generate fallbacks
              %w(jpg png).each do |ext|
                `#{options[:inkscape_bin]} #{basename}.svg --export-png=#{basename}.#{ext} #{options[:inkscape_options]} --without-gui`
                builder.say_status :svg_fallback, "#{basename}.#{ext}"
              end
            end
          end
        end
      end
      alias :included :registered
    end
  end
end