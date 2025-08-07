<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<style>
    .spaced-date {
        margin-left: 10px;
        color: #888;
        font-size: 0.9em;
    }
    
    .review-item hr {
        margin-top: 1rem;
        margin-bottom: 1rem;
    }
    
    .review-content {
        /* 기본적으로 3줄만 보여주고 나머지는 ... 처리 */
        display: -webkit-box;
        -webkit-line-clamp: 3;
        -webkit-box-orient: vertical;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: pre-wrap; 
    }
    
    /* 더보기가 눌렸을 때 전체 내용을 보여주기 위한 클래스 */
    .review-content.expanded {
        display: block;
        -webkit-line-clamp: unset;
        overflow: visible;
    }
    
    /* 더보기 버튼 스타일 */
    .more-btn {
        background: none;
        border: none;
        color: #007bff;
        cursor: pointer;
        padding: 0;
        margin-top: 5px;
        font-size: 0.9em;
        font-weight: bold;
        /* 처음에는 숨겨둠 */
        display: none;
    }
</style>

<c:set var="validReviewCount" value="0" />

<c:forEach var="review" items="${reviewList}">
    <c:if test="${not empty review.reviewContent}">
        <c:set var="validReviewCount" value="${validReviewCount + 1}" />
        <div class="review-item">
            <p>
                <strong>${review.memberId}</strong>님     
                <span class="created-at spaced-date" data-created-at="${review.createdAt}"></span>
            </p>
            
            <!--  HTML 구조 변경 -->
            <div class="review-content">${fn:escapeXml(review.reviewContent)}</div>
            <button class="more-btn">더보기</button>
            
        </div>
        <hr>
    </c:if>
</c:forEach>

<!-- 출력된 유효 코멘트가 없으면 안내 문구 출력 -->
<c:if test="${validReviewCount == 0}">
    <div class="text-muted small mt-2">작성된 리뷰가 없습니다.</div>
</c:if>

<script>
    document.querySelectorAll('.created-at').forEach(function(el) {
        const raw = el.dataset.createdAt;
        if (!raw) return;
        const date = new Date(raw);
        const formatted = date.getFullYear() + '.' +
                          String(date.getMonth() + 1).padStart(2, '0') + '.' +
                          String(date.getDate()).padStart(2, '0') + ' ' +
                          String(date.getHours()).padStart(2, '0') + ':' +
                          String(date.getMinutes()).padStart(2, '0');
        el.textContent = formatted;
    });

    document.querySelectorAll('.review-item').forEach(function(item) {
        const content = item.querySelector('.review-content');
        const moreBtn = item.querySelector('.more-btn');
        
        // scrollHeight: 요소의 전체 높이 (숨겨진 부분 포함)
        // clientHeight: 요소의 화면에 보이는 높이
        // 전체 높이가 보이는 높이보다 크면, 텍스트가 잘렸다는 의미
        if (content.scrollHeight > content.clientHeight) {
            moreBtn.style.display = 'block'; // 더보기 버튼 표시
        }
        
        moreBtn.addEventListener('click', function() {
            content.classList.toggle('expanded');
            if (content.classList.contains('expanded')) {
                moreBtn.textContent = '접기';
            } else {
                moreBtn.textContent = '더보기';
            }
        });
    });
</script>
