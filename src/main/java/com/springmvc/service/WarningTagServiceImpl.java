package com.springmvc.service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import com.springmvc.domain.WarningTag;
import com.springmvc.repository.WarningTagRepository;

public class WarningTagServiceImpl implements WarningTagService  {

	@Autowired
	private WarningTagRepository warningTagRepository;
	
	@Override
	public List<WarningTag> getAllWarningTags() {
		return warningTagRepository.getAllWarningTags();
	}

	//문장 그룹화
	@Override
	public Map<String, List<String>> getGroupedWarningTagsByMovieId(long movieId) {
		List<WarningTag> tags = warningTagRepository.getWarningTagsByMovieId(movieId);
		Map<String, List<String>> groupedTags = new LinkedHashMap<>();
		for (WarningTag tag : tags) {
            String category = tag.getCategory();
            String sentence = tag.getSentence();
            groupedTags.computeIfAbsent(category, k -> new ArrayList<>()).add(sentence);
        }

        return groupedTags;
	}


	@Override
	public List<Long> getWarningTagIdsByMovieId(long movieId) {
		List<WarningTag> existingTags = warningTagRepository.getWarningTagsByMovieId(movieId);
        List<Long> tagIds = new ArrayList<>();
        for (WarningTag tag : existingTags) {
            tagIds.add(tag.getId());
        }
        return tagIds;
    }

	//삭제
	@Override
	@Transactional 
	public void updateMovieWarningTags(long movieId, List<Long> warningTagIds) {
		warningTagRepository.deleteWarningTagsByMovieId(movieId);

        if (warningTagIds == null || warningTagIds.isEmpty()) {
            return;
        }
        warningTagRepository.addWarningTagsToMovie(movieId, warningTagIds);
    }

}
