require 'jumpstart_auth'
require 'klout'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing MicroBlogger"
    @client = JumpstartAuth.twitter
    Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
  end

  def tweet(message)
  	if message.length <= 140
  		@client.update(message)
  		puts "Tweet posted"
  	else
  		puts "Error: tweet length exceeds 140 characters"
  	end
	end

	#direct message
  def dm(target, message)
  	screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
  	if screen_names.include? target
	  	puts "Trying to send #{target} this direct message:"
		  puts message
		  message = "d @#{target} #{message}"
		  tweet(message)
		else
			puts "Error: you can only DM people who are following you"
		end
	end

	def followers_list
		screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
	end

	def spam_my_followers(message)
		followers = followers_list
		followers.each do |screen_name|
			dm(screen_name, message)
		end
	end

  def everyones_last_tweet
    friends = @client.friends
    friends.sort_by { |friend| @client.user(friend).screen_name.downcase }
    friends.each do |friend|
      puts "#{@client.user(friend).screen_name} tweeted:"# print each friend's screen_name
      puts "#{@client.user(friend).status.text}"# print each friend's last message
      puts "at #{@client.user(friend).status.created_at.strftime("%A, %b %d")}"# print time of past tweet
      puts ""  # Just print a blank line to separate people
    end
  end

	def shorten(original_url)
	  # Shortening Code
	  puts "Shortening this URL: #{original_url}"
	  bitly.shorten(original_url).short_url
	end

  def klout_score
    friends = @client.friends.collect{|f| @client.user(f).screen_name}
    friends.each do |friend|
    	puts "#{@client.user(friend).screen_name}"# print your friend's screen_name
    	identity = Klout::Identity.find_by_screen_name(@client.user(friend).screen_name)
    	user = Klout::User.new(identity.id)
      puts "#{user.score.score}"# print your friends's Klout score
      puts "" #Print a blank line to separate each friend
    end
  end

	def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
	  while command != "q"
	    printf "enter command: "
	    input = gets.chomp
	    parts = input.split(" ")
	    command = parts[0]
	    case command
    		when 'q' then puts "Goodbye!"
    		when 't' then tweet(parts[1..-1].join(" "))#parts[1..-1] = tweet to be posted
    		when 'dm' then dm(parts[1], parts[2..-1].join(" "))#parts[1] = target to send DM to; parts[2..-1] = message to be sent
    		when 'spam' then spam_my_followers(parts[1..-1].join(" "))#parts[1..-1] = message to be sent
    		when 'elt' then everyones_last_tweet
    		when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
    		else puts "Sorry, I don't know how to #{command}"
  		end
	  end
  end

end

blogger = MicroBlogger.new
blogger.run
blogger.klout_score