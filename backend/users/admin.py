from django.contrib import admin
from django.contrib.auth.hashers import make_password
from django import forms
from .models import User, Role

class UserAdminForm(forms.ModelForm):
    password_input = forms.CharField(
        widget=forms.PasswordInput, required=False,
        help_text="Leave blank to keep current password"
    )
    class Meta:
        model = User
        fields = ['email', 'role', 'is_active']

    def save(self, commit=True):
        user = super().save(commit=False)
        pwd = self.cleaned_data.get('password_input')
        if pwd:
            user.password_hash = make_password(pwd)
        if commit:
            user.save()
        return user

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    form = UserAdminForm
    list_display = ['email', 'role', 'is_active']
    list_filter = ['role', 'is_active']
    search_fields = ['email']

@admin.register(Role)
class RoleAdmin(admin.ModelAdmin):
    list_display = ['id', 'name']
