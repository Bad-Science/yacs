class Catalog::CatalogUpdater
  class << self

  def full_update
    new_state = catalog.current
    diff_courses_2 new_state
  end

  def quick_update

  end

  private

  def diff_courses courses
    old_courses = {}
    new_courses = {}
    Courses.find_each do |course|
      old_courses[course.uid] = course;
    end
    courses.each do |course|
      new_courses[course.uid] = course;
    end

    # delete stale courses
    old_courses.each |uid, course| do
      course.destroy unless new_courses[uid].present?
    end

    new_courses.each |uid, course| do
      if old_courses[uid].present?
        old_courses[uid].update_attributes course.attributes.compact
      else
        course.save!
      end
    end
  end

  def diff_courses_2 courses
    Course.find_each do |course|
      course.destroy unless new_courses[uid].present?
    end

    courses.each do |course|
      current_course = Course.find_by course.attributes.pluck :department_id, :number
      if current_course.present?
        current_course.update_attributes course.attributes.compact
      else
        course.save!
      end
    end
  end

  def diff_sections sections
    
  end

  def catalog
    Rails.application.config.catalog
  end

end
