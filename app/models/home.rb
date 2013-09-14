class Home
  
  def self.events
    today = Date.today.beginning_of_day
    Event.featured.between(today, today + 2.weeks).
      order('start_at ASC').select{|e|
        e.authorized?(nil) and not e.page.obscure? and
        (! e.prev || e.prev.start_at < today) and
        e.messages.empty?
      }
  end
  
  def self.next_message
    today = Date.today.beginning_of_day
    Message.between(today, today + 1.week).first;
  end
  
  def self.previous_message
    today = Date.today.beginning_of_day
    Message.between(today - 2.weeks, today).last;
  end
  
end