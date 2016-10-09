class Catalog::CatalogUpdater
  class << self

  def full_update
    new_state = catalog.current
    diff_set new_state
  end

  def quick_update

  end

  private

  def diff_set courses
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

  def catalog
    Rails.application.config.catalog
  end

end
