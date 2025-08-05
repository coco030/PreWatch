package com.springmvc.domain;

public class MovieWarningTag {
	
	public MovieWarningTag() {}
	
	private long movieId;
    private long warningTagId;
	
    
    @Override
	public String toString() {
		return "MovieWarningTag [movieId=" + movieId + ", warningTagId=" + warningTagId + "]";
	}

	
	public MovieWarningTag(long movieId, long warningTagId) {
		super();
		this.movieId = movieId;
		this.warningTagId = warningTagId;
	}
	
	
	public long getMovieId() {
		return movieId;
	}
	public void setMovieId(long movieId) {
		this.movieId = movieId;
	}
	public long getWarningTagId() {
		return warningTagId;
	}
	public void setWarningTagId(long warningTagId) {
		this.warningTagId = warningTagId;
	}
    
    

}
