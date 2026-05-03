# Generated manually to add slot duration for generated appointment slots.

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('doctors', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='doctoravailability',
            name='slot_duration_minutes',
            field=models.PositiveIntegerField(default=30),
        ),
    ]
