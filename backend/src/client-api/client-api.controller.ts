import { Body, Controller, Delete, Get, Param, Post, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { StudyMode } from '@prisma/client';
import { ClientApiService } from './client-api.service';

@ApiTags('client')
@Controller('client')
export class ClientApiController {
  constructor(private readonly clientApi: ClientApiService) {}

  @Get('bootstrap')
  bootstrap(@Query('appKey') appKey?: string, @Query('userId') userId?: string) {
    return this.clientApi.bootstrap(appKey, userId);
  }

  @Get('subjects')
  listSubjects(@Query('appKey') appKey?: string) {
    return this.clientApi.listSubjects(appKey);
  }

  @Post('subjects/:subjectId/default')
  setDefaultSubject(
    @Param('subjectId') subjectId: string,
    @Body('userId') userId?: string,
  ) {
    return this.clientApi.setDefaultSubject(subjectId, userId);
  }

  @Get('subjects/:subjectId/stats')
  subjectStats(
    @Param('subjectId') subjectId: string,
    @Query('userId') userId?: string,
  ) {
    return this.clientApi.subjectStats(subjectId, userId);
  }

  @Get('subjects/:subjectId/catalog')
  catalogTree(
    @Param('subjectId') subjectId: string,
    @Query('userId') userId?: string,
    @Query('mode') mode?: StudyMode,
  ) {
    return this.clientApi.catalogTree(
      subjectId,
      userId,
      mode === StudyMode.exam ? StudyMode.exam : StudyMode.practice,
    );
  }

  @Get('catalogs/:catalogId/questions')
  listQuestions(
    @Param('catalogId') catalogId: string,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    return this.clientApi.listQuestions(
      catalogId,
      Number(limit ?? 20),
      Number(offset ?? 0),
    );
  }

  @Post('practice/start')
  startPractice(
    @Body()
    body: {
      catalogId?: string;
      questionIds?: string[];
      count?: number;
      mode?: 'practice' | 'exam';
    },
  ) {
    return this.clientApi.startPractice(body);
  }

  @Post('practice/random')
  startRandomPractice(
    @Body()
    body: {
      subjectId: string;
      catalogIds?: string[];
      count?: number;
    },
  ) {
    return this.clientApi.startRandomPractice(body);
  }

  @Post('answers')
  submitAnswer(
    @Body()
    body: {
      userId?: string;
      appKey?: string;
      questionId: string;
      catalogId?: string;
      mode?: StudyMode;
      values?: string[];
      text?: string;
      actualScore?: number;
    },
  ) {
    return this.clientApi.submitAnswer(body);
  }

  @Post('exams/submit')
  submitExam(
    @Body()
    body: {
      userId?: string;
      appKey?: string;
      title: string;
      mode: string;
      answers: Array<{
        questionId: string;
        values?: string[];
        text?: string;
      }>;
      durationMinutes?: number;
    },
  ) {
    return this.clientApi.submitExam(body);
  }

  @Get('records')
  listRecords(
    @Query('mode') mode: 'practice' | 'exam' = 'practice',
    @Query('userId') userId?: string,
    @Query('appKey') appKey?: string,
  ) {
    return this.clientApi.listRecords(userId, mode, appKey);
  }

  @Delete('records')
  deleteRecords(
    @Query('mode') mode: 'practice' | 'exam' = 'practice',
    @Query('userId') userId?: string,
    @Query('appKey') appKey?: string,
    @Query('recordId') recordId?: string,
  ) {
    return this.clientApi.deleteRecords({ userId, appKey, mode, recordId });
  }

  @Get('favorites')
  listFavorites(
    @Query('userId') userId?: string,
    @Query('limit') limit?: string,
    @Query('subjectId') subjectId?: string,
  ) {
    return this.clientApi.listFavorites(userId, Number(limit ?? 50), subjectId);
  }

  @Post('favorites/:questionId/toggle')
  toggleFavorite(
    @Param('questionId') questionId: string,
    @Body('userId') userId?: string,
  ) {
    return this.clientApi.toggleFavorite(userId, questionId);
  }

  @Get('wrong-questions')
  listWrongQuestions(
    @Query('userId') userId?: string,
    @Query('limit') limit?: string,
    @Query('subjectId') subjectId?: string,
  ) {
    return this.clientApi.listWrongQuestions(userId, Number(limit ?? 50), subjectId);
  }

  @Post('wrong-questions/clear')
  clearWrongQuestions(
    @Body()
    body: {
      userId?: string;
      questionIds?: string[];
      subjectId?: string;
    },
  ) {
    return this.clientApi.clearWrongQuestions(body);
  }

  @Delete('wrong-questions/:questionId')
  removeWrongQuestion(
    @Param('questionId') questionId: string,
    @Query('userId') userId?: string,
  ) {
    return this.clientApi.removeWrongQuestion(userId, questionId);
  }

  @Post('progress/reset')
  resetProgress(
    @Body()
    body: {
      userId?: string;
      appKey?: string;
      mode?: StudyMode;
      catalogIds: string[];
    },
  ) {
    return this.clientApi.resetProgress(body);
  }

  @Post('feedback')
  submitFeedback(
    @Body()
    body: {
      userId?: string;
      appKey?: string;
      questionId?: string;
      type?: string;
      content: string;
      contact?: string;
      payload?: unknown;
    },
  ) {
    return this.clientApi.submitFeedback(body);
  }

  @Get('resources')
  listResources(
    @Query('bankId') bankId?: string,
    @Query('appKey') appKey?: string,
  ) {
    return this.clientApi.listResources({ bankId, appKey });
  }
}
