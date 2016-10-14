class Catalog::CatalogUpdater
  class << self

  def full_update
    new_state = map_uids catalog.full
    diff_set Course.all, %i(department_id number), new_state

    Course.find_each do |course|
      diff_set course.sections, %i(name), new_state[course.uid].sections
    end
  end

  def quick_update
    catalog.quick.each do |section|
      update Section.find_by section.attributes.extract %i(name)
    end
  end

  private

  def diff_set scope, uid_fields, records
    scope.find_each do |record|
      record.destroy unless records[record.uid].present?
    end

    records.each do |new_record|
      old_record = scope.find_by new_record.attributes.extract uid_fields
      old_record.present? ? update old_record, new_record : new_record.save!
    end
  end

  def update old_record, new_record
    old_record.update_attributes new_record.attributes.compact
  end

  def map_uids records, fields
    mapped_records = {}
    records.each do |record|
      mapped_records[record.uid] = record;
    end
    mapped_records
  end

  def catalog
    # Yacs::Catalog::Adapter
  end
end


class Section
  def uid
    name
  end
end

class Course
  def uid
    "#{department_id}-#{number}"
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