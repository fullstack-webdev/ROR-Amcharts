module Utils

  def category_name_from_id(id)
    case id.to_i
      when 0
        return 'TrippingIn(Connection)'
      when 1
        return 'TrippingIn(Pipe Moving Time)'
      when 2
        return 'TrippingOut(Connection)'
      when 3
        return 'TrippingOut(Pipe Moving Time)'
      when 4
        return 'Drilling(Connection)'
      when 5
        return 'Drilling(Weight To Weight)'
      when 6
        return 'Drilling(Treatment)'
      when 7
        return 'Drilling(Drilling)'
    end
  end

end