class DriverUpdateController < PackageController

  before_filter :require_project
  before_filter :require_package


  def create
    @repositories = @project.each_repository.map{|repo| {:project => @project.name,
        :repo => repo.name, :archs => repo.each_arch.map{|arch| arch.to_s} } }
    @packages = find_cached(Package, :all, :project => @project.name, :expires_in => 30.seconds ).
      each_entry.map{|package| {:name => package.name, :type => 'repopackage'}}[0..50]
  end


  def edit
    # find the 'create_dud_kiwi' service
    services = Service.find :project => @project, :package => @package
    services = Service.new( :project => @project, :package => @package ) unless services
    service = services.data.find( "service[@name='create_dud_kiwi']" ).first

    if service.blank?
      flash[:warn] = "No Driver update disk section found in _services, creating new"
      redirect_to :action => :create, :project => @project, :package => @package and return
    end

    @repositories = service.find( 'param[@name="instrepo"]' ).map{|repo| {:project => repo.content.split('/')[0], :repo => repo.content.split('/')[1] } }

    @packages = []
    @packages |= service.find( 'param[@name="repopackage"]' ).map{|package| {:name => package.content, :type => 'repopackage'} }
    @packages |=  service.find( 'param[@name="instsys"]' ).map{|package| {:name => package.content, :type => 'instsys'} }
    @packages |=  service.find( 'param[@name="module"]' ).map{|package| {:name => package.content, :type => 'module'} }

    render :create
  end


  def save

    # find the 'create_dud_kiwi' service
    services = Service.find :project => @project, :package => @package
    services = Service.new( :project => @project, :package => @package ) unless services

    dud_params = {} 
    services.addService( 'create_dud_kiwi', -1, dud_params )

    services.save

    #flash[:warn] = "Saving of DUD kiwi configs is not yet implemented"
    flash[:success] = "Saved Driver update disk service."
    redirect_to :controller => :package, :action => :show, :project => @project, :package => @package
  end

end