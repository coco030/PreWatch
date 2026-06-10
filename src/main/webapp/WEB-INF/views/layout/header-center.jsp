<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="header-center">
    <form action="${pageContext.request.contextPath}/search" method="get" class="search-form">
        <c:set var="selectedPosterMode" value="${param.posterMode}" />
        <c:if test="${selectedPosterMode ne 'horror' and selectedPosterMode ne 'adult' and selectedPosterMode ne 'horror_adult' and selectedPosterMode ne 'all'}">
            <c:set var="selectedPosterMode" value="off" />
        </c:if>
        <input type="hidden" name="posterMode" class="poster-mode-input" value="${selectedPosterMode}" />
        <div class="search-input-wrapper">
            <input type="text" 
                   name="query" 
                   placeholder="영화 검색..." 
                   class="search-input"
                   autocomplete="off" />
			<button type="submit" class="search-btn" title="검색">
			    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
			        <circle cx="11" cy="11" r="8"></circle>
			        <path d="M 21 21l-4.35-4.35"></path>
			    </svg>
			</button>
        </div>
        <div class="search-filter-popover" role="group" aria-label="포스터 가림 설정" hidden>
            <div class="search-filter-heading">
                <strong>포스터를 가려드릴게요</strong>
                <span>검색어와 별도로 적용됩니다.</span>
            </div>
            <div class="search-filter-options">
                <button type="button" class="search-filter-option ${selectedPosterMode eq 'off' ? 'is-active' : ''}" data-poster-mode="off">끄기</button>
                <button type="button" class="search-filter-option ${(selectedPosterMode eq 'horror' or selectedPosterMode eq 'horror_adult') ? 'is-active' : ''}" data-poster-mode="horror">공포·긴장감</button>
                <button type="button" class="search-filter-option ${(selectedPosterMode eq 'adult' or selectedPosterMode eq 'horror_adult') ? 'is-active' : ''}" data-poster-mode="adult">성인등급</button>
                <button type="button" class="search-filter-option ${selectedPosterMode eq 'all' ? 'is-active' : ''}" data-poster-mode="all">전체 가리기</button>
            </div>
        </div>
    </form>
</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const searchForm = document.querySelector('.search-form');
    if (!searchForm) {
        return;
    }

    const searchInput = searchForm.querySelector('.search-input');
    const searchFilterPopover = searchForm.querySelector('.search-filter-popover');
    const posterModeInput = searchForm.querySelector('.poster-mode-input');
    const optionButtons = Array.from(searchForm.querySelectorAll('.search-filter-option'));
    const offButton = searchForm.querySelector('.search-filter-option[data-poster-mode="off"]');
    const horrorButton = searchForm.querySelector('.search-filter-option[data-poster-mode="horror"]');
    const adultButton = searchForm.querySelector('.search-filter-option[data-poster-mode="adult"]');
    const allButton = searchForm.querySelector('.search-filter-option[data-poster-mode="all"]');

    function openSearchFilters() {
        searchForm.classList.add('is-filter-open');
        if (searchFilterPopover) {
            searchFilterPopover.hidden = false;
        }
    }

    function closeSearchFilters() {
        searchForm.classList.remove('is-filter-open');
        if (searchFilterPopover) {
            searchFilterPopover.hidden = true;
        }
    }

    if (searchInput) {
        searchInput.addEventListener('focus', openSearchFilters);
        searchInput.addEventListener('click', openSearchFilters);
    }

    function getPosterModeFromFilters() {
        if (allButton && allButton.classList.contains('is-active')) {
            return 'all';
        }

        const horrorSelected = horrorButton && horrorButton.classList.contains('is-active');
        const adultSelected = adultButton && adultButton.classList.contains('is-active');

        if (horrorSelected && adultSelected) {
            return 'horror_adult';
        }
        if (horrorSelected) {
            return 'horror';
        }
        if (adultSelected) {
            return 'adult';
        }
        return 'off';
    }

    function syncPosterMode() {
        const mode = getPosterModeFromFilters();
        if (offButton) {
            offButton.classList.toggle('is-active', mode === 'off');
        }
        if (posterModeInput) {
            posterModeInput.value = mode;
        }
        window.dispatchEvent(new CustomEvent('prewatch:posterModeChanged', {
            detail: {
                posterMode: mode
            }
        }));
    }

    optionButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            const mode = button.dataset.posterMode || 'off';

            if (mode === 'off') {
                optionButtons.forEach(function (item) {
                    item.classList.toggle('is-active', item === button);
                });
            } else if (mode === 'all') {
                optionButtons.forEach(function (item) {
                    item.classList.toggle('is-active', item === allButton);
                });
            } else {
                if (offButton) {
                    offButton.classList.remove('is-active');
                }
                if (allButton) {
                    allButton.classList.remove('is-active');
                }
                button.classList.toggle('is-active');
            }

            syncPosterMode();
        });
    });

    document.addEventListener('click', function (event) {
        if (!searchForm.contains(event.target)) {
            closeSearchFilters();
        }
    });

    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            closeSearchFilters();
        }
    });
});
</script>
