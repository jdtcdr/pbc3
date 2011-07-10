class Message < ActiveRecord::Base
  belongs_to :message_set
  belongs_to :author
  has_many :verse_ranges, :autosave => true, :dependent => :destroy
  has_many :message_files, :order => 'file_content_type', :dependent => :destroy
  acts_as_url :title, :sync_url => true
  acts_as_audited
  
  validates :title, :presence => true
  
  def to_param
    url
  end
  
  before_save :setup_verse_ranges
  
  def setup_verse_ranges
    ranges = VerseParser.new(self.verses).ranges
    verse_ranges.clear
    ranges.each do |range|
      verse_ranges.build(:begin_index => range[:begin][:index],
        :end_index => range[:end][:index])
    end
  end
  
  def intersects?(verse_span)
    verse_ranges.detect{|r| r.intersects?(verse_span)}
  end
  
  def self.find_by_verses(verses)
    ranges = verses.is_a?(String) ? VerseParser.new(verses).ranges : verses
    return [] if ranges.empty?
    wheres = []
    ranges.each do |range|
      wheres << "(verse_ranges.end_index >= #{range[:begin][:index]}" +
        "AND verse_ranges.begin_index <= #{range[:end][:index]})"
    end
    Message.includes(:verse_ranges).
      where(wheres.join(' OR ')).
      order('messages.date desc').
      order('verse_ranges.begin_index')
  end
  
  def self.count_for_book(book)
    ranges = VerseParser.new(book).ranges
    return 0 if ranges.empty?
    Message.includes(:verse_ranges).
      where('verse_ranges.end_index >= ? AND verse_ranges.begin_index <= ?',
        ranges.first[:begin][:index], ranges.first[:end][:index]).
      count
  end
  
  def self.between(start_date, end_date)
    where('messages.date' => start_date..end_date)
  end
  
  def self.between_with_full_sets(start_date, end_date)
    # find message_sets between dates
    message_sets = MessageSet.between(start_date, end_date)
    # remove any sets that end after the end date
    message_sets = message_sets.all.delete_if{|set|
      set.messages(true) # reload
      not set.ends_within?(start_date, end_date)}
    message_set_ids = message_sets.map{|set| set.id}
    
    if message_set_ids.empty?
      Message.between(start_date, end_date).order('date DESC')
    else
      Message.
        where('message_set_id IN (?) OR ' +
          '(message_set_id IS NULL AND ' +
            'messages.date >= ? AND messages.date < ?)',
          message_set_ids, start_date, end_date).
        order('date DESC')
    end
  end
  
  def emebedded_content
    message_file = message_files.where(
      "file_file_name LIKE '%.txt' OR file_file_name LIKE '%.html'").first
    return '' unless message_file
    'TBD'
  end
  
  def audio_message_files
    message_files.select{|mf| mf.audio?}
  end
  
  def self.merge_messages_and_sets(messages, message_sets)
    result = []
    while (not messages.empty? or not message_sets.empty?) do
      if not messages.empty? and
        (message_sets.empty? or
          message_sets.first.messages.first.date < messages.first.date)
        result << messages.shift
      else
        result << message_sets.shift
      end
    end
    result
  end
  
  searchable do
    text :title, :default_boost => 2
  end
  
end
