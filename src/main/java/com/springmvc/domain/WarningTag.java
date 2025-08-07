package com.springmvc.domain;

import java.time.LocalDateTime;
import java.util.Objects;

public class WarningTag {

	public WarningTag() {	}
	
	private long id;
    private String category;
    private String sentence;
    private int sortOrder;
    private LocalDateTime  createdAt;
    
	public WarningTag(long id, String category, String sentence, int sortOrder, LocalDateTime createdAt) {
		super();
		this.id = id;
		this.category = category;
		this.sentence = sentence;
		this.sortOrder = sortOrder;
		this.createdAt = createdAt;
	}
	
	@Override
	public String toString() {
		return "WarningTag [id=" + id + ", category=" + category + ", sentence=" + sentence + ", sortOrder=" + sortOrder
				+ ", createdAt=" + createdAt + "]";
	}
	
	@Override
    public int hashCode() {
        return Objects.hash(id);
    }

	@Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        WarningTag that = (WarningTag) o;
   
        return Objects.equals(id, that.id);
    }
	public long getId() {
		return id;
	}
	public void setId(long id) {
		this.id = id;
	}
	public String getCategory() {
		return category;
	}
	public void setCategory(String category) {
		this.category = category;
	}
	public String getSentence() {
		return sentence;
	}
	public void setSentence(String sentence) {
		this.sentence = sentence;
	}
	public int getSortOrder() {
		return sortOrder;
	}
	public void setSortOrder(int sortOrder) {
		this.sortOrder = sortOrder;
	}
	public LocalDateTime getCreatedAt() {
		return createdAt;
	}
	public void setCreatedAt(LocalDateTime createdAt) {
		this.createdAt = createdAt;
	}   

}