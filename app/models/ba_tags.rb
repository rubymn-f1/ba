module BaTags
  include Radiant::Taggable

  tag "ba" do |tag|
    tag.locals.site_user = controller.__send__(:current_site_user) if self.respond_to?(:controller) && controller.respond_to?(:current_site_user)
    tag.expand
  end

  desc %{
    Tags inside this tag refer to the attendance of the current site_user.
  }
  tag "ba:attendance" do |tag|
    tag.locals.attendance = happening_page.attendance(tag.locals.site_user)
    tag.expand
  end

  desc %{
    Renders the contained elements only if the current site_user has NOT signed up for the happening
  }
  tag "ba:attendance:unless" do |tag|
    tag.expand unless tag.locals.attendance
  end

  desc %{
    Renders the contained elements only if the current site_user has signed up for the happening
  }
  tag "ba:attendance:if" do |tag|
    tag.expand if tag.locals.attendance
  end

  desc %{
    Renders the price (currency and amount) of the signed in site_user's attendance
    to the happening.
    
    *Usage:* 
    <pre><code><r:ba:attendance:price [free="free_text"]/></code></pre>
  }
  tag "ba:attendance:price" do |tag|
    price = tag.locals.attendance.actual_price
    free = tag.attr['free'] || '0'
    price ? "#{price.currency} #{price.amount}" : free
  end

  desc %{
    Renders the contained elements only if the current site_user has NOT submitted any presentations
  }
  tag "ba:attendance:unless_presentations" do |tag|
    tag.expand unless tag.locals.attendance.presentations.count > 0
  end

  desc %{
    Renders the contained elements only if the current site_user has submitted any presentations
  }
  tag "ba:attendance:if_presentations" do |tag|
    tag.expand if tag.locals.attendance.presentations.count > 0
  end

  desc %{
    Tags inside this tag refer to the presentations of the current site_user.
  }
  tag "ba:attendance:presentations" do |tag|
    tag.locals.presentations = tag.locals.attendance.presentations
    tag.expand
  end

  desc %{
    Cycles through each of the current site_user's presentations. Inside this tag all page attribute tags
    are mapped to the current presentation.
  }
  tag "ba:attendance:presentations:each" do |tag|
    result = []
    tag.locals.presentations.each do |presentation|
      tag.locals.presentation = presentation
      result << tag.expand
    end
    result
  end

  desc %{
    Renders the title of the current presentation.
  }
  tag "ba:attendance:presentations:each:title" do |tag|
    tag.locals.presentation.title
  end

  desc "Displays event details as hCal" 
  tag "ba:hcal" do |tag|
    description = tag.attr['description']
    location = tag.attr['location']

    %{<div class="vevent">
  <h3 class="summary"><a href="#{url}" class="url">#{title}</a></h3>
  <p class="description">#{description}</p>
  <p>
    <abbr class="dtstart" title="#{starts_at.iso8601}">#{starts_at.to_s(:long)}</abbr>
  </p>
  <p><span class="location">#{location}</span></p>
</div>}
  end

  desc %{
    Renders a signup form for the happening.
    This tag can only be used on attendances/* parts of a Happening page.
    
    NOTE: You MUST make sure the layout used for your page includes the prototype.js
    javascript in the head section:
    
    <pre><code><script src="/javascripts/prototype.js" type="text/javascript"></script></code></pre>
  }
  tag "ba:new_attendance_form" do |tag|
    render_partial('attendances/new')
  end

  desc %{
    Renders a form to edit an existing attendance.
    This tag can be used on the attendances/already part of a Happening page.
    
    NOTE: You MUST make sure the layout used for your page includes the prototype.js
    javascript in the head section:
    
    <pre><code><script src="/javascripts/prototype.js" type="text/javascript"></script></code></pre>
  }
  tag "ba:attendance:form" do |tag|
    render_partial('attendances/edit')
  end
  
  def render_partial(partial)
    page = self
    url = page.url.split('/').reject{|e| e.blank?}
    controller.instance_eval do
      render :locals => {:page => page, :url => url}, :partial => partial
    end
  end
  
  desc %{
    Displays the name of the logged in site_user
  }
  tag "ba:site_user_name" do |tag|
    tag.locals.site_user.name
  end
end