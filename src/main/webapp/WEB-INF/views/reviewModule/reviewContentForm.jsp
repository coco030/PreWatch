<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!-- 부트스트랩 CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
    /* ▼▼▼ 주석: 이 CSS 클래스가 '더 보기' 기능을 제어합니다. ▼▼▼ */
    /* 아래 max-height 값을 조절하여 리뷰가 잘리는 높이를 설정할 수 있습니다. (예: 100px, 5em 등) */
    #reviewContentBox.truncated {
        max-height: 85px;
        overflow: hidden;
        /* 내용 끝이 자연스럽게 가려지는 효과*/
        -webkit-mask-image: linear-gradient(to bottom, black 60%, transparent 100%);
        mask-image: linear-gradient(to bottom, black 60%, transparent 100%);
    }
</style>

<!-- 영화 ID & 로그인 체크 -->
<input type="hidden" id="movieId" value="${movieId}" />
<c:if test="${not empty loginMember}"><input type="hidden" id="memberId" value="${loginMember.id}" /></c:if>

<!-- <h6 class="mb-2 fw-bold"><i class="fas fa-pen me-1"></i>나의 리뷰</h6>  -->

<!-- 리뷰 작성창 -->
<c:set var="writeBoxStyle" value="max-width: 600px; width: 100%;" />
<c:if test="${not empty loginMember && not empty myReview.reviewContent}"><c:set var="writeBoxStyle" value="display: none; max-width: 600px; width: 100%;" /></c:if>

<div id="reviewWriteBox" class="mb-3" style="${writeBoxStyle}" <c:if test="${empty loginMember}">data-bs-toggle="modal" data-bs-target="#loginModal" style="cursor: pointer;"</c:if>>
    <textarea id="reviewContentInput" class="form-control border-0 border-bottom rounded-0 px-1 py-2" rows="1" placeholder="<c:choose><c:when test='${empty loginMember}'>로그인 후 리뷰 작성이 가능합니다.</c:when><c:otherwise>리뷰를 남겨보세요.</c:otherwise></c:choose>" style="width: 100%; resize: vertical; overflow-y: hidden; background-color: transparent;" <c:if test="${empty loginMember}">readonly</c:if>></textarea>
    <div class="text-end mt-2">
        <button class="btn btn-dark btn-sm" id="saveReviewContentBtn" <c:if test="${empty loginMember}">disabled</c:if>>리뷰 저장</button>
    </div>
</div>

<!-- 로그인한 경우에만 리뷰 출력창 보이기 -->
<c:if test="${not empty loginMember && not empty myReview.reviewContent}">
  <div id="reviewDisplayBox" class="mb-3">
    <div id="reviewContentBox" class="mb-2" style="white-space: pre-wrap;">${fn:escapeXml(myReview.reviewContent)}</div>
    <div class="text-end">
        <button class="btn btn-link btn-sm p-0 me-2 d-none" id="toggleReviewBtn" data-state="more">더 보기</button>
        <button class="btn btn-outline-secondary btn-sm me-2" id="editReviewBtn">수정</button>
        <button class="btn btn-outline-danger btn-sm" id="deleteReviewBtn">삭제</button>
    </div>
  </div>
</c:if>

<!-- 로그인 모달 -->
<jsp:include page="/WEB-INF/views/loginModal.jsp" />

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
document.addEventListener("DOMContentLoaded", function () {
    // ---- 리뷰 '작성' 관련 로직 ----
    const input = document.getElementById("reviewContentInput");
    const saveBtn = document.getElementById("saveReviewContentBtn");
    const writtenContent = "${fn:escapeXml(myReview.reviewContent)}";

    if (input) {
        input.value = writtenContent;
        const autoResize = (el) => { el.style.height = "auto"; el.style.height = el.scrollHeight + "px"; };
        if (writtenContent.trim() !== "") { autoResize(input); }
        input.addEventListener("input", () => autoResize(input));
        input.addEventListener("keydown", function (event) {
            if (event.key === "Enter" && !event.shiftKey) { event.preventDefault(); if (saveBtn) saveBtn.click(); }
        });
    }

    if (saveBtn) {
        saveBtn.addEventListener("click", function () {
            const content = input.value.trim();
            const movieId = document.getElementById("movieId").value;
            if (content === "") { alert("리뷰 내용을 입력해주세요."); return; }
            fetch("${pageContext.request.contextPath}/review/saveContent", {
                method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: new URLSearchParams({ movieId, reviewContent: content })
            }).then(res => res.json()).then(data => {
                if (data.success) { alert("리뷰가 저장되었습니다."); location.reload(); }
                else { alert(data.message || "저장 실패"); }
            });
        });
    }

    const editBtn = document.getElementById("editReviewBtn");
    if (editBtn) {
        editBtn.addEventListener("click", function () {
            document.getElementById("reviewWriteBox").style.display = "block";
            document.getElementById("reviewDisplayBox").style.display = "none";
            const input = document.getElementById("reviewContentInput");
            const autoResize = (el) => { el.style.height = "auto"; el.style.height = el.scrollHeight + "px"; };
            autoResize(input); input.focus();
        });
    }

    const deleteBtn = document.getElementById("deleteReviewBtn");
    if (deleteBtn) {
        deleteBtn.addEventListener("click", function () {
            if (!confirm("정말 리뷰를 삭제하시겠습니까?")) return;
            const movieId = document.getElementById("movieId").value;
            fetch("${pageContext.request.contextPath}/review/deleteReview", {
                method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: new URLSearchParams({ movieId })
            }).then(res => res.json()).then(data => {
                if (data.success) { alert("삭제되었습니다."); location.reload(); }
                else { alert(data.message || "삭제 실패"); }
            });
        });
    }

    // ▼▼▼ '더 보기' 기능 핵심 로직 (수정됨) ▼▼▼
    const reviewContentBox = document.getElementById("reviewContentBox");
    const toggleReviewBtn = document.getElementById("toggleReviewBtn");

    if (reviewContentBox && toggleReviewBtn) {
        // CSS에 정의된 max-height 값. CSS와 일치해야 합니다.
        const maxHeight = 85; 

        // 실제 컨텐츠 높이(scrollHeight)가 지정된 최대 높이보다 큰지 직접 비교합니다.
        if (reviewContentBox.scrollHeight > maxHeight) {
            reviewContentBox.classList.add("truncated");
            toggleReviewBtn.classList.remove("d-none");
        }

        toggleReviewBtn.addEventListener("click", function() {
            const currentState = this.dataset.state;
            if (currentState === "more") {
                reviewContentBox.classList.remove("truncated");
                this.textContent = "간단히 보기";
                this.dataset.state = "less";
            } else {
                reviewContentBox.classList.add("truncated");
                this.textContent = "더 보기";
                this.dataset.state = "more";
            }
        });
    }
});
</script>