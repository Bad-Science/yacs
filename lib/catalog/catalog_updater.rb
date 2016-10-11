class Catalog::CatalogUpdater
  class << self

  def full_update
    new_state = catalog.current
    diff_set Course, [:department_id, :number], catalog.current
    new_state.each do |course|
      diff_set Section, [:course_id, :name], course.sections
    end
  end

  def quick_update
    catalog.quick.each do |section|
      update Section.find_by section.pluck :course_id, :name
    end
  end

  private

  def diff_set klass, uid_fields, records
    new_courses = map_uids records
    klass.find_each do |record|
      record.destroy unless new_courses[uid].present?
    end

    records.each do |new_record|
      old_record = klass.find_by new_record.attributes.pluck uid_fields
      old_record.present? ? update old_record, new_record : new_record.save!
    end
  end

  def update old_record, new_record
    old_record.update_attributes new_record.attributes.compact
  end

  def map_uids records
    mapped_records = {}
    records.each do |record|
      mapped_records[record.uid] = record;
    end
    mapped_records
  end

  def catalog
    Rails.application.config.catalog
  end
end


  # def diff_courses courses
  #   old_courses = {}
  #   new_courses = {}
  #   Courses.find_each do |course|
  #     old_courses[course.uid] = course;
  #   end
  #   courses.each do |course|
  #     new_courses[course.uid] = course;
  #   end

  #   # delete stale courses
  #   old_courses.each |uid, course| do
  #     course.destroy unless new_courses[uid].present?
  #   end

  #   new_courses.each |uid, course| do
  #     if old_courses[uid].present?
  #       old_courses[uid].update_attributes course.attributes.compact
  #     else
  #       course.save!
  #     end
  #   end
  # end

  # def diff_courses_2 courses
  #   Course.find_each do |course|
  #     course.destroy unless new_courses[uid].present?
  #   end

  #   courses.each do |course|
  #     current_course = Course.find_by course.attributes.pluck :department_id, :number
  #     if current_course.present?
  #       current_course.update_attributes course.attributes.compact
  #     else
  #       course.save!
  #     end
  #   end
  # end