require 'tempfile'
class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]
  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = Contact.all
    render json: @contacts
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params)
    respond_to do |format|
      if @contact.save
        format.html { redirect_to @contact, notice: 'Contact was successfully created.' }
        format.json { render :show, status: :created, location: @contact }
      else
        format.html { render :new }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to @contact, notice: 'Contact was successfully updated.' }
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: 'Contact was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def export
    file = File.new('data.txt', 'w')
    # It should be only specific contacts (not all in db)
    Contact.all.each do |contact|
      new_line = ""
      contact.attributes.each do |name, value|
        new_line += name + ":" + value.to_s + ";"
      end
      file.write(new_line+"\n")
    end
    file.close
    send_file(file.path,
      :type => 'text',
      :disposition => "attachment; filename=your_file_name.txt")
  end

  def import
    new_contacts = []
    columns = [:name, :phone, :email, :bio, :birthday]
    file_path = params['file'].path
    file = File.open(file_path, 'r')
    file.each_line do |line|
      # To init the contact object from this line
      object = []
      line.strip.split(";").each do |elem|
        key = elem.split(":")[0].to_sym
        if columns.include? key
          object << elem.split(":")[1]
        end
      end
      new_contacts << object
    end
    Contact.delete_all
    Contact.import columns, new_contacts, :validate => false
    file.close
    render json: {success: true}
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:name, :phone, :email, :bio, :birthday)
    end
end
