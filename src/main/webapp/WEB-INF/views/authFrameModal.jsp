<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
    .auth-frame-dialog {
        width: min(440px, calc(100vw - 24px));
        max-width: 440px;
    }

    .auth-frame-content {
        border: 0;
        border-radius: 10px;
        overflow: hidden;
        box-shadow: 0 16px 48px rgba(33, 37, 41, 0.24);
    }

    .auth-frame-body {
        height: min(680px, calc(100vh - 96px));
        min-height: 520px;
        padding: 0;
        background: #f8f9fa;
    }

    .auth-frame {
        display: block;
        width: 100%;
        height: 100%;
        border: 0;
        background: #f8f9fa;
    }

    @media (max-width: 576px) {
        .auth-frame-dialog {
            width: calc(100vw - 16px);
            margin-right: auto;
            margin-left: auto;
        }

        .auth-frame-body {
            height: calc(100vh - 80px);
            min-height: 480px;
        }
    }
</style>

<div class="modal fade" id="authFrameModal" tabindex="-1" aria-labelledby="authFrameModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered auth-frame-dialog">
        <div class="modal-content auth-frame-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold" id="authFrameModalLabel">로그인</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
            </div>
            <div class="modal-body auth-frame-body">
                <iframe id="authFrame" class="auth-frame" title="계정 화면"></iframe>
            </div>
        </div>
    </div>
</div>

<script>
(function () {
    if (window.PrewatchAuthFrameModalReady) {
        return;
    }
    window.PrewatchAuthFrameModalReady = true;

    function openAuthFrame(url, title) {
        const modalElement = document.getElementById('authFrameModal');
        const frame = document.getElementById('authFrame');
        const modalTitle = document.getElementById('authFrameModalLabel');

        if (!modalElement || !frame || !window.bootstrap || !window.bootstrap.Modal) {
            window.location.href = url;
            return;
        }

        if (modalTitle) {
            modalTitle.textContent = title || '로그인';
        }

        frame.src = url;
        window.bootstrap.Modal.getOrCreateInstance(modalElement).show();
    }

    function syncAuthFrameTitle() {
        const frame = document.getElementById('authFrame');
        const modalTitle = document.getElementById('authFrameModalLabel');
        if (!frame || !modalTitle || !frame.contentWindow) {
            return;
        }

        try {
            const path = frame.contentWindow.location.pathname;
            if (path.indexOf('/member/join') !== -1) {
                modalTitle.textContent = '회원가입';
            } else if (path.indexOf('/auth/login') !== -1) {
                modalTitle.textContent = '로그인';
            } else if (path.indexOf('/member') === -1 && path.indexOf('/auth') === -1 && path.indexOf('join') !== -1) {
                modalTitle.textContent = '가입 완료';
            }
        } catch (error) {
            // Same-origin pages can be read; ignore if the browser blocks access.
        }
    }

    window.openPrewatchAuthFrameModal = function (options) {
        const modalOptions = options || {};
        openAuthFrame(modalOptions.url, modalOptions.title);
    };

    document.addEventListener('click', function (event) {
        const trigger = event.target.closest('[data-auth-frame-url]');
        if (!trigger) {
            return;
        }

        event.preventDefault();
        openAuthFrame(trigger.getAttribute('data-auth-frame-url'), trigger.getAttribute('data-auth-frame-title'));
    });

    document.addEventListener('hidden.bs.modal', function (event) {
        if (event.target && event.target.id === 'authFrameModal') {
            const frame = document.getElementById('authFrame');
            if (frame) {
                frame.src = 'about:blank';
            }
        }
    });

    document.addEventListener('DOMContentLoaded', function () {
        const frame = document.getElementById('authFrame');
        if (frame) {
            frame.addEventListener('load', syncAuthFrameTitle);
        }
    });
})();
</script>
